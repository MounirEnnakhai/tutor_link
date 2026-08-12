import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/review_entity.dart';
import '../../../domain/entities/tutor_entity.dart';
import '../../models/tutor_model.dart';

class TutorRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  TutorRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  CollectionReference get _tutorsRef =>
      _firestore.collection(AppConstants.tutorsCollection);

  Future<TutorModel> getTutorById(String tutorId) async {
    // Try direct document lookup first
    final doc = await _tutorsRef.doc(tutorId).get();
    if (doc.exists) return TutorModel.fromFirestore(doc);

    // Fallback: search by userId field
    final query = await _tutorsRef
        .where('userId', isEqualTo: tutorId)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      return TutorModel.fromFirestore(query.docs.first);
    }

    // Fallback: create a basic tutor profile from users collection
    final userDoc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(tutorId)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      // Auto-create the missing tutor document
      final tutorData = {
        'userId': tutorId,
        'email': data['email'] ?? '',
        'fullName': data['fullName'] ?? 'Tutor',
        'photoUrl': data['photoUrl'],
        'biography': '',
        'subjects': [],
        'educationLevel': '',
        'qualifications': [],
        'yearsOfExperience': 0,
        'teachingLanguages': [],
        'rating': 0.0,
        'totalReviews': 0,
        'totalStudents': 0,
        'verificationStatus': 'notSubmitted',
        'teachingModes': [],
        'certifications': [],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await _tutorsRef.doc(tutorId).set(tutorData);
      final newDoc = await _tutorsRef.doc(tutorId).get();
      return TutorModel.fromFirestore(newDoc);
    }

    throw Exception('Tutor not found');
  }

  Future<TutorModel?> getTutorByUserId(String userId) async {
    final query = await _tutorsRef
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return TutorModel.fromFirestore(query.docs.first);
  }

  Future<List<TutorModel>> getFeaturedTutors({int limit = 10}) async {
    final query = await _tutorsRef
        .where('isActive', isEqualTo: true)
        .where('verificationStatus', isEqualTo: 'verified')
        .orderBy('rating', descending: true)
        .limit(limit)
        .get();

    return query.docs.map(TutorModel.fromFirestore).toList();
  }

  Future<List<TutorModel>> searchTutors({
    required SearchFilter filter,
    double? userLat,
    double? userLng,
    int limit = 20,
    String? lastDocumentId,
  }) async {
    Query query = _tutorsRef.where('isActive', isEqualTo: true);

    if (filter.subject != null && filter.subject!.isNotEmpty) {
      query = query.where('subjects', arrayContains: filter.subject);
    }

    if (filter.educationLevel != null && filter.educationLevel!.isNotEmpty) {
      query = query.where('educationLevel', isEqualTo: filter.educationLevel);
    }

    if (filter.language != null && filter.language!.isNotEmpty) {
      query = query.where('teachingLanguages', arrayContains: filter.language);
    }

    if (filter.minRating != null) {
      query = query.where('rating', isGreaterThanOrEqualTo: filter.minRating);
    }

    switch (filter.sortBy) {
      case 'rating':
        query = query.orderBy('rating', descending: true);
        break;
      default:
        query = query.orderBy('rating', descending: true);
    }

    if (lastDocumentId != null) {
      final lastDoc = await _tutorsRef.doc(lastDocumentId).get();
      query = query.startAfterDocument(lastDoc);
    }

    query = query.limit(limit);

    final result = await query.get();
    List<TutorModel> tutors =
    result.docs.map(TutorModel.fromFirestore).toList();

    if (userLat != null && userLng != null && filter.maxDistanceKm != null) {
      tutors = tutors.where((tutor) {
        if (tutor.location == null) return filter.onlineOnly == true;
        final dist = _calculateDistance(
          userLat,
          userLng,
          tutor.location!.latitude,
          tutor.location!.longitude,
        );
        return dist <= filter.maxDistanceKm!;
      }).toList();
    }

    return tutors;
  }

  Future<List<TutorModel>> getNearbyTutors({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    final latDelta = radiusKm / 111.0;
    final lngDelta = radiusKm / (111.0 * cos(latitude * pi / 180));

    final query = await _tutorsRef
        .where('isActive', isEqualTo: true)
        .where('location.latitude', isGreaterThan: latitude - latDelta)
        .where('location.latitude', isLessThan: latitude + latDelta)
        .get();

    final tutors = query.docs.map(TutorModel.fromFirestore).toList();

    return tutors.where((t) {
      if (t.location == null) return false;
      final dist = _calculateDistance(
        latitude,
        longitude,
        t.location!.latitude,
        t.location!.longitude,
      );
      return dist <= radiusKm;
    }).toList();
  }

  Future<TutorModel> createTutorProfile(TutorEntity tutor) async {
    final model = tutor as TutorModel;
    await _tutorsRef.doc(model.id).set(model.toFirestore());
    return model;
  }

  Future<TutorModel> updateTutorProfile(TutorEntity tutor) async {
    final model = tutor as TutorModel;
    await _tutorsRef.doc(model.id).update(model.toFirestore());
    return model;
  }

  Future<String> uploadProfilePicture({
    required String tutorId,
    required File image,
  }) async {
    final ref = _storage
        .ref()
        .child(AppConstants.profilePicturesPath)
        .child('$tutorId.jpg');

    await ref.putFile(image);
    final url = await ref.getDownloadURL();

    await _tutorsRef.doc(tutorId).update({'photoUrl': url});
    return url;
  }

  Future<void> submitVerificationRequest({
    required String tutorId,
    required List<File> documents,
  }) async {
    final urls = <String>[];
    for (var i = 0; i < documents.length; i++) {
      final ref = _storage
          .ref()
          .child(AppConstants.verificationDocsPath)
          .child(tutorId)
          .child('doc_$i.pdf');
      await ref.putFile(documents[i]);
      urls.add(await ref.getDownloadURL());
    }

    await _firestore
        .collection(AppConstants.verificationRequestsCollection)
        .add({
      'tutorId': tutorId,
      'documents': urls,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _tutorsRef.doc(tutorId).update({
      'verificationStatus': 'pending',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) *
            cos(_toRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180;
}