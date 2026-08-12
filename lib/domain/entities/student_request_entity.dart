import 'package:equatable/equatable.dart';

class StudentRequestEntity extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String? studentPhotoUrl;
  final String subject;
  final String title;
  final String description;
  final double? maxBudget;
  final String type;
  final String preferredMode;
  final String? location;
  final String educationLevel;
  final String status;
  final DateTime createdAt;

  const StudentRequestEntity({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.studentPhotoUrl,
    required this.subject,
    required this.title,
    required this.description,
    this.maxBudget,
    required this.type,
    required this.preferredMode,
    this.location,
    required this.educationLevel,
    this.status = 'open',
    required this.createdAt,
  });

  bool get isOpen => status == 'open';

  @override
  List<Object?> get props => [id, studentId, subject, status];
}