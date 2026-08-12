import 'dart:io';
import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/offer_entity.dart';
import '../entities/review_entity.dart';
import '../entities/tutor_entity.dart';

// ✅ MUST be before any class declarations
export '../entities/review_entity.dart' show SearchFilter;

/// =======================
/// TUTOR REPOSITORY
/// =======================
abstract class TutorRepository {
  Future<Either<Failure, TutorEntity>> getTutorById(String tutorId);

  Future<Either<Failure, TutorEntity?>> getTutorByUserId(String userId);

  Future<Either<Failure, List<TutorEntity>>> getFeaturedTutors({
    int limit = 10,
  });

  Future<Either<Failure, List<TutorEntity>>> searchTutors({
    required SearchFilter filter,
    double? userLat,
    double? userLng,
    int? limit,
    String? lastDocumentId,
  });

  Future<Either<Failure, TutorEntity>> createTutorProfile(TutorEntity tutor);

  Future<Either<Failure, TutorEntity>> updateTutorProfile(TutorEntity tutor);

  Future<Either<Failure, String>> uploadProfilePicture({
    required String tutorId,
    required File image,
  });

  Future<Either<Failure, void>> submitVerificationRequest({
    required String tutorId,
    required List<File> documents,
  });

  Future<Either<Failure, List<TutorEntity>>> getNearbyTutors({
    required double latitude,
    required double longitude,
    required double radiusKm,
  });
}

/// =======================
/// OFFER REPOSITORY
/// =======================
abstract class OfferRepository {
  Future<Either<Failure, List<OfferEntity>>> getFeaturedOffers({
    int limit = 10,
  });

  Future<Either<Failure, List<OfferEntity>>> getOffersByTutor(
      String tutorId,
      );

  Future<Either<Failure, List<OfferEntity>>> searchOffers({
    required SearchFilter filter,
    int? limit,
    String? lastDocumentId,
  });

  Future<Either<Failure, OfferEntity>> getOfferById(String offerId);

  Future<Either<Failure, OfferEntity>> createOffer(OfferEntity offer);

  Future<Either<Failure, OfferEntity>> updateOffer(OfferEntity offer);

  Future<Either<Failure, void>> deleteOffer(String offerId);

  Future<Either<Failure, void>> pauseOffer(String offerId);

  Future<Either<Failure, void>> activateOffer(String offerId);
}

/// =======================
/// REVIEW REPOSITORY
/// =======================
abstract class ReviewRepository {
  Future<Either<Failure, List<ReviewEntity>>> getReviewsByTutor(
      String tutorId,
      );

  Future<Either<Failure, ReviewEntity>> createReview(ReviewEntity review);

  Future<Either<Failure, void>> deleteReview(String reviewId);

  Future<Either<Failure, bool>> hasStudentReviewedTutor({
    required String studentId,
    required String tutorId,
  });
}

/// =======================
/// FAVORITE REPOSITORY
/// =======================
abstract class FavoriteRepository {
  Future<Either<Failure, List<TutorEntity>>> getFavorites(String studentId);

  Future<Either<Failure, void>> addFavorite({
    required String studentId,
    required String tutorId,
  });

  Future<Either<Failure, void>> removeFavorite({
    required String studentId,
    required String tutorId,
  });

  Future<Either<Failure, bool>> isFavorite({
    required String studentId,
    required String tutorId,
  });

  Stream<List<String>> watchFavoriteIds(String studentId);
}