import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/offer_entity.dart';

class OfferModel extends OfferEntity {
  const OfferModel({
    required super.id,
    required super.tutorId,
    required super.tutorName,
    super.tutorPhotoUrl,
    required super.subject,
    required super.title,
    required super.description,
    required super.type,
    super.status,
    super.hourlyRate,
    super.teachingMode,
    super.availabilitySchedule,
    super.monthlyPrice,
    super.maxStudents,
    super.availableSeats,
    super.isOnline,
    super.classSchedule,
    super.location,
    super.latitude,
    super.longitude,
    super.imageUrl,
    super.tags,
    required super.createdAt,
    super.updatedAt,
  });

  factory OfferModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OfferModel.fromMap(data, doc.id);
  }

  factory OfferModel.fromMap(Map<String, dynamic> data, String id) {
    List<ScheduleSlot> _parseSchedule(List<dynamic>? list) {
      if (list == null) return [];
      return list.map((s) {
        final slot = s as Map<String, dynamic>;
        return ScheduleSlot(
          day: slot['day'] ?? '',
          startTime: slot['startTime'] ?? '',
          endTime: slot['endTime'] ?? '',
        );
      }).toList();
    }

    return OfferModel(
      id: id,
      tutorId: data['tutorId'] ?? '',
      tutorName: data['tutorName'] ?? '',
      tutorPhotoUrl: data['tutorPhotoUrl'],
      subject: data['subject'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] == 'groupClass' ? OfferType.groupClass : OfferType.privateLesson,
      status: _parseStatus(data['status']),
      hourlyRate: (data['hourlyRate'] as num?)?.toDouble(),
      teachingMode: data['teachingMode'],
      availabilitySchedule: _parseSchedule(data['availabilitySchedule']),
      monthlyPrice: (data['monthlyPrice'] as num?)?.toDouble(),
      maxStudents: data['maxStudents'],
      availableSeats: data['availableSeats'],
      isOnline: data['isOnline'],
      classSchedule: _parseSchedule(data['classSchedule']),
      location: data['location'],
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      imageUrl: data['imageUrl'],
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    List<Map<String, dynamic>> _scheduleToList(List<ScheduleSlot> slots) {
      return slots
          .map((s) => {'day': s.day, 'startTime': s.startTime, 'endTime': s.endTime})
          .toList();
    }

    return {
      'tutorId': tutorId,
      'tutorName': tutorName,
      'tutorPhotoUrl': tutorPhotoUrl,
      'subject': subject,
      'title': title,
      'description': description,
      'type': type == OfferType.groupClass ? 'groupClass' : 'privateLesson',
      'status': status.name,
      'hourlyRate': hourlyRate,
      'teachingMode': teachingMode,
      'availabilitySchedule': _scheduleToList(availabilitySchedule),
      'monthlyPrice': monthlyPrice,
      'maxStudents': maxStudents,
      'availableSeats': availableSeats,
      'isOnline': isOnline,
      'classSchedule': _scheduleToList(classSchedule),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static OfferStatus _parseStatus(String? status) {
    switch (status) {
      case 'paused':
        return OfferStatus.paused;
      case 'deleted':
        return OfferStatus.deleted;
      default:
        return OfferStatus.active;
    }
  }
}
