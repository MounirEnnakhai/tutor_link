import 'package:equatable/equatable.dart';

enum UserRole { student, tutor, admin }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? photoUrl;
  final UserRole role;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? phoneNumber;
  final bool isActive;
  final bool isProfileComplete;

  // Student specific
  final String? educationLevel;
  final String? grade;
  final String? city;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.photoUrl,
    required this.role,
    this.isEmailVerified = false,
    required this.createdAt,
    this.updatedAt,
    this.phoneNumber,
    this.isActive = true,
    this.isProfileComplete = false,
    this.educationLevel,
    this.grade,
    this.city,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? photoUrl,
    UserRole? role,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? phoneNumber,
    bool? isActive,
    bool? isProfileComplete,
    String? educationLevel,
    String? grade,
    String? city,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      educationLevel: educationLevel ?? this.educationLevel,
      grade: grade ?? this.grade,
      city: city ?? this.city,
    );
  }

  bool get isStudent => role == UserRole.student;
  bool get isTutor => role == UserRole.tutor;
  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object?> get props => [
    id, email, fullName, photoUrl, role,
    isEmailVerified, createdAt, phoneNumber,
    isActive, isProfileComplete, educationLevel, grade, city,
  ];
}