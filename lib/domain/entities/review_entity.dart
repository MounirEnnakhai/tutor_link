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

// ─── Search Filter ────────────────────────────────────────────────────────────

class SearchFilter extends Equatable {
  final String? subject;
  final String? offerType;
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
  final String? sortBy;

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

  // Sentinel so null can actually clear a field
  static const _clear = Object();

  SearchFilter copyWith({
    Object? subject = _clear,
    Object? offerType = _clear,
    Object? minHourlyRate = _clear,
    Object? maxHourlyRate = _clear,
    Object? minMonthlyPrice = _clear,
    Object? maxMonthlyPrice = _clear,
    Object? maxDistanceKm = _clear,
    Object? onlineOnly = _clear,
    Object? educationLevel = _clear,
    Object? minRating = _clear,
    Object? teachingMode = _clear,
    Object? language = _clear,
    Object? sortBy = _clear,
  }) {
    return SearchFilter(
      subject: subject == _clear ? this.subject : subject as String?,
      offerType: offerType == _clear ? this.offerType : offerType as String?,
      minHourlyRate: minHourlyRate == _clear
          ? this.minHourlyRate
          : minHourlyRate as double?,
      maxHourlyRate: maxHourlyRate == _clear
          ? this.maxHourlyRate
          : maxHourlyRate as double?,
      minMonthlyPrice: minMonthlyPrice == _clear
          ? this.minMonthlyPrice
          : minMonthlyPrice as double?,
      maxMonthlyPrice: maxMonthlyPrice == _clear
          ? this.maxMonthlyPrice
          : maxMonthlyPrice as double?,
      maxDistanceKm: maxDistanceKm == _clear
          ? this.maxDistanceKm
          : maxDistanceKm as double?,
      onlineOnly:
      onlineOnly == _clear ? this.onlineOnly : onlineOnly as bool?,
      educationLevel: educationLevel == _clear
          ? this.educationLevel
          : educationLevel as String?,
      minRating:
      minRating == _clear ? this.minRating : minRating as double?,
      teachingMode: teachingMode == _clear
          ? this.teachingMode
          : teachingMode as String?,
      language: language == _clear ? this.language : language as String?,
      sortBy: sortBy == _clear ? this.sortBy : sortBy as String?,
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
    subject, offerType, minHourlyRate, maxHourlyRate,
    minMonthlyPrice, maxMonthlyPrice, maxDistanceKm,
    onlineOnly, educationLevel, minRating, teachingMode,
    language, sortBy,
  ];
}