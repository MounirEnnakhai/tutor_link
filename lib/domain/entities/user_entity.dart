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
    );
  }

  bool get isStudent => role == UserRole.student;
  bool get isTutor => role == UserRole.tutor;
  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        photoUrl,
        role,
        isEmailVerified,
        createdAt,
        phoneNumber,
        isActive,
      ];
}
