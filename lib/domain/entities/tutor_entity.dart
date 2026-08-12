import 'package:equatable/equatable.dart';

enum VerificationStatus { pending, verified, rejected, notSubmitted }

class LocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? country;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.country,
  });

  @override
  List<Object?> get props => [latitude, longitude, address, city, country];
}

class TutorEntity extends Equatable {
  final String id;
  final String userId;
  final String fullName;
  final String? photoUrl;
  final String biography;
  final List<String> subjects;
  final String educationLevel;
  final List<String> qualifications;
  final int yearsOfExperience;
  final List<String> teachingLanguages;
  final double rating;
  final int totalReviews;
  final LocationEntity? location;
  final String? phoneNumber;
  final String? email;
  final VerificationStatus verificationStatus;
  final List<String> teachingModes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int totalStudents;
  final List<String> certifications;

  const TutorEntity({
    required this.id,
    required this.userId,
    required this.fullName,
    this.photoUrl,
    required this.biography,
    required this.subjects,
    required this.educationLevel,
    required this.qualifications,
    required this.yearsOfExperience,
    required this.teachingLanguages,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.location,
    this.phoneNumber,
    this.email,
    this.verificationStatus = VerificationStatus.notSubmitted,
    required this.teachingModes,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.totalStudents = 0,
    this.certifications = const [],
  });

  bool get isVerified => verificationStatus == VerificationStatus.verified;

  TutorEntity copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? photoUrl,
    String? biography,
    List<String>? subjects,
    String? educationLevel,
    List<String>? qualifications,
    int? yearsOfExperience,
    List<String>? teachingLanguages,
    double? rating,
    int? totalReviews,
    LocationEntity? location,
    String? phoneNumber,
    String? email,
    VerificationStatus? verificationStatus,
    List<String>? teachingModes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalStudents,
    List<String>? certifications,
  }) {
    return TutorEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      biography: biography ?? this.biography,
      subjects: subjects ?? this.subjects,
      educationLevel: educationLevel ?? this.educationLevel,
      qualifications: qualifications ?? this.qualifications,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      teachingLanguages: teachingLanguages ?? this.teachingLanguages,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      location: location ?? this.location,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      teachingModes: teachingModes ?? this.teachingModes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalStudents: totalStudents ?? this.totalStudents,
      certifications: certifications ?? this.certifications,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        fullName,
        subjects,
        rating,
        totalReviews,
        verificationStatus,
        isActive,
      ];
}
