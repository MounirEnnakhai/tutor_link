import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/tutor_entity.dart';

class TutorModel extends TutorEntity {
  const TutorModel({
    required super.id,
    required super.userId,
    required super.fullName,
    super.photoUrl,
    required super.biography,
    required super.subjects,
    required super.educationLevel,
    required super.qualifications,
    required super.yearsOfExperience,
    required super.teachingLanguages,
    super.rating,
    super.totalReviews,
    super.location,
    super.phoneNumber,
    super.email,
    super.verificationStatus,
    required super.teachingModes,
    super.isActive,
    required super.createdAt,
    super.updatedAt,
    super.totalStudents,
    super.certifications,
  });

  factory TutorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TutorModel.fromMap(data, doc.id);
  }

  factory TutorModel.fromMap(Map<String, dynamic> data, String id) {
    LocationEntity? location;
    if (data['location'] != null) {
      final locData = data['location'] as Map<String, dynamic>;
      location = LocationEntity(
        latitude: (locData['latitude'] as num).toDouble(),
        longitude: (locData['longitude'] as num).toDouble(),
        address: locData['address'],
        city: locData['city'],
        country: locData['country'],
      );
    }

    return TutorModel(
      id: id,
      userId: data['userId'] ?? '',
      fullName: data['fullName'] ?? '',
      photoUrl: data['photoUrl'],
      biography: data['biography'] ?? '',
      subjects: List<String>.from(data['subjects'] ?? []),
      educationLevel: data['educationLevel'] ?? '',
      qualifications: List<String>.from(data['qualifications'] ?? []),
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
      teachingLanguages: List<String>.from(data['teachingLanguages'] ?? []),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: data['totalReviews'] ?? 0,
      location: location,
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      verificationStatus: _parseVerificationStatus(data['verificationStatus']),
      teachingModes: List<String>.from(data['teachingModes'] ?? []),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      totalStudents: data['totalStudents'] ?? 0,
      certifications: List<String>.from(data['certifications'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'biography': biography,
      'subjects': subjects,
      'educationLevel': educationLevel,
      'qualifications': qualifications,
      'yearsOfExperience': yearsOfExperience,
      'teachingLanguages': teachingLanguages,
      'rating': rating,
      'totalReviews': totalReviews,
      'location': location != null
          ? {
              'latitude': location!.latitude,
              'longitude': location!.longitude,
              'address': location!.address,
              'city': location!.city,
              'country': location!.country,
              'geoPoint': GeoPoint(location!.latitude, location!.longitude),
            }
          : null,
      'phoneNumber': phoneNumber,
      'email': email,
      'verificationStatus': verificationStatus.name,
      'teachingModes': teachingModes,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'totalStudents': totalStudents,
      'certifications': certifications,
    };
  }

  static VerificationStatus _parseVerificationStatus(String? status) {
    switch (status) {
      case 'pending':
        return VerificationStatus.pending;
      case 'verified':
        return VerificationStatus.verified;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.notSubmitted;
    }
  }
}
