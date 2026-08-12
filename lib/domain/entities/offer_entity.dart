import 'package:equatable/equatable.dart';

enum OfferType { privateLesson, groupClass }

enum OfferStatus { active, paused, deleted }

class ScheduleSlot extends Equatable {
  final String day; // Monday, Tuesday, etc.
  final String startTime; // HH:mm
  final String endTime;

  const ScheduleSlot({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [day, startTime, endTime];
}

class OfferEntity extends Equatable {
  final String id;
  final String tutorId;
  final String tutorName;
  final String? tutorPhotoUrl;
  final String subject;
  final String title;
  final String description;
  final OfferType type;
  final OfferStatus status;

  // Private lesson specific
  final double? hourlyRate;
  final String? teachingMode; // online, at tutor, at student
  final List<ScheduleSlot> availabilitySchedule;

  // Group class specific
  final double? monthlyPrice;
  final int? maxStudents;
  final int? availableSeats;
  final bool? isOnline;
  final List<ScheduleSlot> classSchedule;

  // Common
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OfferEntity({
    required this.id,
    required this.tutorId,
    required this.tutorName,
    this.tutorPhotoUrl,
    required this.subject,
    required this.title,
    required this.description,
    required this.type,
    this.status = OfferStatus.active,
    this.hourlyRate,
    this.teachingMode,
    this.availabilitySchedule = const [],
    this.monthlyPrice,
    this.maxStudents,
    this.availableSeats,
    this.isOnline,
    this.classSchedule = const [],
    this.location,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
  });

  bool get isPrivateLesson => type == OfferType.privateLesson;
  bool get isGroupClass => type == OfferType.groupClass;
  bool get isActive => status == OfferStatus.active;

  double get displayPrice {
    if (isPrivateLesson) return hourlyRate ?? 0;
    return monthlyPrice ?? 0;
  }

  String get priceLabel {
    if (isPrivateLesson) return '/hr';
    return '/mo';
  }

  OfferEntity copyWith({
    String? id,
    String? tutorId,
    String? tutorName,
    String? tutorPhotoUrl,
    String? subject,
    String? title,
    String? description,
    OfferType? type,
    OfferStatus? status,
    double? hourlyRate,
    String? teachingMode,
    List<ScheduleSlot>? availabilitySchedule,
    double? monthlyPrice,
    int? maxStudents,
    int? availableSeats,
    bool? isOnline,
    List<ScheduleSlot>? classSchedule,
    String? location,
    double? latitude,
    double? longitude,
    String? imageUrl,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OfferEntity(
      id: id ?? this.id,
      tutorId: tutorId ?? this.tutorId,
      tutorName: tutorName ?? this.tutorName,
      tutorPhotoUrl: tutorPhotoUrl ?? this.tutorPhotoUrl,
      subject: subject ?? this.subject,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      teachingMode: teachingMode ?? this.teachingMode,
      availabilitySchedule: availabilitySchedule ?? this.availabilitySchedule,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      maxStudents: maxStudents ?? this.maxStudents,
      availableSeats: availableSeats ?? this.availableSeats,
      isOnline: isOnline ?? this.isOnline,
      classSchedule: classSchedule ?? this.classSchedule,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tutorId,
        subject,
        title,
        type,
        status,
        hourlyRate,
        monthlyPrice,
      ];
}
