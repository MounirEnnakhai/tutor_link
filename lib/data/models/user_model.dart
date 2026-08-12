import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.photoUrl,
    required super.role,
    super.isEmailVerified,
    required super.createdAt,
    super.updatedAt,
    super.phoneNumber,
    super.isActive,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      photoUrl: data['photoUrl'],
      role: _parseRole(data['role']),
      isEmailVerified: data['isEmailVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      phoneNumber: data['phoneNumber'],
      isActive: data['isActive'] ?? true,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      photoUrl: data['photoUrl'],
      role: _parseRole(data['role']),
      isEmailVerified: data['isEmailVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      phoneNumber: data['phoneNumber'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'role': role.name,
      'isEmailVerified': isEmailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'phoneNumber': phoneNumber,
      'isActive': isActive,
    };
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'tutor':
        return UserRole.tutor;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }

  UserModel copyWithModel({
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
    return UserModel(
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
}
