import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String tutorId;
  final String studentId;
  final String studentName;
  final String? studentPhotoUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final bool isVisible;

  const ReviewEntity({
    required this.id,
    required this.tutorId,
    required this.studentId,
    required this.studentName,
    this.studentPhotoUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.isVisible = true,
  });

  @override
  List<Object?> get props => [id, tutorId, studentId, rating, comment];
}

class SearchFilter extends Equatable {
  final String? subject;
  final String? offerType; // 'private' | 'group' | null
  final double? minHourlyRate;
  final double? maxHourlyRate;
  final double? minMonthlyPrice;
  final double? maxMonthlyPrice;
  final double? maxDistanceKm;
  final bool? onlineOnly;
  final String? educationLevel;
  final double? minRating;
  final String? teachingMode;
  final String? language;
  final String? sortBy; // 'rating' | 'price_asc' | 'price_desc' | 'distance'

  const SearchFilter({
    this.subject,
    this.offerType,
    this.minHourlyRate,
    this.maxHourlyRate,
    this.minMonthlyPrice,
    this.maxMonthlyPrice,
    this.maxDistanceKm,
    this.onlineOnly,
    this.educationLevel,
    this.minRating,
    this.teachingMode,
    this.language,
    this.sortBy,
  });

  SearchFilter copyWith({
    String? subject,
    String? offerType,
    double? minHourlyRate,
    double? maxHourlyRate,
    double? minMonthlyPrice,
    double? maxMonthlyPrice,
    double? maxDistanceKm,
    bool? onlineOnly,
    String? educationLevel,
    double? minRating,
    String? teachingMode,
    String? language,
    String? sortBy,
  }) {
    return SearchFilter(
      subject: subject ?? this.subject,
      offerType: offerType ?? this.offerType,
      minHourlyRate: minHourlyRate ?? this.minHourlyRate,
      maxHourlyRate: maxHourlyRate ?? this.maxHourlyRate,
      minMonthlyPrice: minMonthlyPrice ?? this.minMonthlyPrice,
      maxMonthlyPrice: maxMonthlyPrice ?? this.maxMonthlyPrice,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      onlineOnly: onlineOnly ?? this.onlineOnly,
      educationLevel: educationLevel ?? this.educationLevel,
      minRating: minRating ?? this.minRating,
      teachingMode: teachingMode ?? this.teachingMode,
      language: language ?? this.language,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get isEmpty =>
      subject == null &&
      offerType == null &&
      minHourlyRate == null &&
      maxHourlyRate == null &&
      maxDistanceKm == null &&
      onlineOnly == null &&
      educationLevel == null &&
      minRating == null;

  @override
  List<Object?> get props => [
        subject,
        offerType,
        minHourlyRate,
        maxHourlyRate,
        minMonthlyPrice,
        maxMonthlyPrice,
        maxDistanceKm,
        onlineOnly,
        educationLevel,
        minRating,
        teachingMode,
        language,
        sortBy,
      ];
}
