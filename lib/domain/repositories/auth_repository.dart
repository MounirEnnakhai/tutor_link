import 'dart:io';
import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Stream of auth state changes
  Stream<UserEntity?> get authStateChanges;

  /// Get the currently signed-in user
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Sign in with email and password
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Register with email and password
  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  });

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Update user profile
  Future<Either<Failure, UserEntity>> updateProfile({
    String? fullName,
    String? phoneNumber,
    File? profileImage,
  });

  /// Delete account
  Future<Either<Failure, void>> deleteAccount();
}
