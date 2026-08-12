import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/errors/failures.dart';
import '../../data/datasources/auth/auth_remote_datasource.dart';
import '../../domain/entities/user_entity.dart';

// ─── Infrastructure Providers ──────────────────────────────────────────────────

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(scopes: ['email', 'profile']);
});

// ─── DataSource Providers ─────────────────────────────────────────────────────

final authDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(firebaseStorageProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

// ─── Auth State Stream ────────────────────────────────────────────────────────

final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  return dataSource.authStateChanges;
});

// ─── Current User Provider ────────────────────────────────────────────────────

final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

// ─── Auth Notifier ────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final AuthRemoteDataSource _dataSource;

  AuthNotifier(this._dataSource) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() async {
    final user = await _dataSource.getCurrentUser();
    state = AsyncValue.data(user);
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _dataSource.signInWithEmail(
        email: email,
        password: password,
      );
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _dataSource.signInWithGoogle();
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _dataSource.registerWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    await _dataSource.signOut();
    state = const AsyncValue.data(null);
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _dataSource.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? phoneNumber,
    File? profileImage,
  }) async {
    try {
      final updated = await _dataSource.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        profileImage: profileImage,
      );
      state = AsyncValue.data(updated);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  return AuthNotifier(ref.watch(authDataSourceProvider));
});
