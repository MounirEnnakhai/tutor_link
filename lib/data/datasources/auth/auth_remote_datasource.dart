import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/user_entity.dart';
import '../../models/user_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSource({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _storage = storage,
        _googleSignIn = googleSignIn;

  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _getUserFromFirestore(user.uid);
    });
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _getUserFromFirestore(user.uid);
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = await _getUserFromFirestore(credential.user!.uid);
      if (user == null) throw const AuthFailure('User data not found');
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.code));
    }
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw const AuthFailure('Google sign-in cancelled');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final uid = userCredential.user!.uid;

      // Check if user exists in Firestore
      final existing = await _getUserFromFirestore(uid);
      if (existing != null) return existing;

      // Create new user document for Google sign-in
      // Create new user document for Google sign-in
      final newUser = UserModel(
        id: uid,
        email: googleUser.email,
        fullName: googleUser.displayName ?? 'User',
        photoUrl: googleUser.photoUrl,
        role: UserRole.student,
        isEmailVerified: true,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .set(newUser.toFirestore());

// Google users default to student — no tutor profile needed
      return newUser;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.code));
    }
  }

  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user!.updateDisplayName(fullName);
      await credential.user!.sendEmailVerification();

      final newUser = UserModel(
        id: credential.user!.uid,
        email: email,
        fullName: fullName,
        role: role,
        createdAt: DateTime.now(),
      );

      // Save user to Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(newUser.id)
          .set(newUser.toFirestore());

      // If tutor, create empty tutor profile
      if (role == UserRole.tutor) {
        await _createEmptyTutorProfile(newUser.id, email, fullName);
      }

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.code));
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.code));
    }
  }

  Future<UserModel> updateProfile({
    String? fullName,
    String? phoneNumber,
    File? profileImage,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthFailure('Not authenticated');

    String? photoUrl;
    if (profileImage != null) {
      photoUrl = await _uploadProfilePicture(user.uid, profileImage);
    }

    if (fullName != null) {
      await user.updateDisplayName(fullName);
    }

    final updates = <String, dynamic>{
      if (fullName != null) 'fullName': fullName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .update(updates);

    final updated = await _getUserFromFirestore(user.uid);
    if (updated == null) throw const AuthFailure('Failed to fetch updated user');
    return updated;
  }

  // ─── Private Helpers ────────────────────────────────────────────────────────

  Future<UserModel?> _getUserFromFirestore(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<String> _uploadProfilePicture(String userId, File image) async {
    final ref = _storage
        .ref()
        .child(AppConstants.profilePicturesPath)
        .child('$userId.jpg');

    await ref.putFile(image);
    return ref.getDownloadURL();
  }

  Future<void> _createEmptyTutorProfile(
      String userId, String email, String fullName) async {
    await _firestore
        .collection(AppConstants.tutorsCollection)
        .doc(userId)
        .set({
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'biography': '',
      'subjects': [],
      'educationLevel': '',
      'qualifications': [],
      'yearsOfExperience': 0,
      'teachingLanguages': [],
      'rating': 0.0,
      'totalReviews': 0,
      'verificationStatus': 'notSubmitted',
      'teachingModes': [],
      'isActive': true,
      'totalStudents': 0,
      'certifications': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account with this email already exists';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters)';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
