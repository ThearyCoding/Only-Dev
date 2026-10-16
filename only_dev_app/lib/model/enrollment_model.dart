import 'dart:convert';
import 'courses_model.dart';

class EnrollmentModel {
  final String id;
  final String courseId;
  final String userId;
  final String enrollmentType;
  final String status;
  final double pricePaid;
  final String currency;
  final DateTime enrolledAt;
  final DateTime? expiresAt;
  final int percentComplete;
  final bool isCompleted;
  final String? lastAccessedLessonId;
  final CourseModel? course;

  EnrollmentModel({
    required this.id,
    required this.courseId,
    required this.userId,
    this.enrollmentType = 'free',
    this.status = 'active',
    this.pricePaid = 0.0,
    this.currency = 'USD',
    required this.enrolledAt,
    this.expiresAt,
    this.percentComplete = 0,
    this.isCompleted = false,
    this.lastAccessedLessonId,
    this.course,
  });

  // Backward compatibility getters for existing UI widgets
  bool get isRegistered => status == 'active';
  String get docId => id;
  DateTime get timestamp => enrolledAt;
  String get categoryId => course?.categoryId ?? '';
  int get progressPercentage => percentComplete;

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    try {
      final dynamic dyn = value;
      return dyn.toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }

  factory EnrollmentModel.fromMap(Map<String, dynamic> map) {
    CourseModel? courseObj;
    if (map['course'] != null && map['course'] is Map) {
      courseObj = CourseModel.fromMap(map['course'] as Map<String, dynamic>);
    } else if (map['courseId'] != null && map['courseId'] is Map) {
      courseObj = CourseModel.fromMap(map['courseId'] as Map<String, dynamic>);
    }

    final progressMap = map['progress'] as Map<String, dynamic>?;

    return EnrollmentModel(
      id: (map['id'] ?? map['_id'] ?? map['enrollment_id'] ?? map['enrollmentId'] ?? map['docId'] ?? '').toString(),
      courseId: (map['course_id'] is Map
              ? map['course_id']['_id']
              : map['course_id'] ?? (map['courseId'] is Map ? map['courseId']['_id'] : map['courseId']) ?? '')
          .toString(),
      userId: (map['user_id'] is Map
              ? map['user_id']['_id']
              : map['user_id'] ?? (map['userId'] is Map ? map['userId']['_id'] : map['userId']) ?? '')
          .toString(),
      enrollmentType: (map['enrollment_type'] ?? map['enrollmentType'] ?? 'free').toString(),
      status: (map['status'] ?? 'active').toString(),
      pricePaid: map['price_paid'] is Map
          ? ((map['price_paid']['amount'] ?? 0) as num).toDouble()
          : (map['pricePaid'] is Map
              ? ((map['pricePaid']['amount'] ?? 0) as num).toDouble()
              : ((map['price_paid'] ?? map['pricePaid'] ?? 0) as num).toDouble()),
      currency: (map['price_paid'] is Map
          ? map['price_paid']['currency']
          : (map['pricePaid'] is Map ? map['pricePaid']['currency'] : map['currency'])) ?? 'USD',
      enrolledAt: _parseDateTime(map['enrolled_at'] ?? map['enrolledAt'] ?? map['timestamp']),
      expiresAt: (map['expires_at'] ?? map['expiresAt']) != null ? _parseDateTime(map['expires_at'] ?? map['expiresAt']) : null,
      percentComplete: progressMap != null
          ? ((progressMap['percent_complete'] ?? progressMap['percentComplete'] ?? 0) as num).toInt()
          : ((map['percent_complete'] ?? map['percentComplete'] ?? 0) as num).toInt(),
      isCompleted: progressMap != null
          ? (progressMap['is_completed'] ?? progressMap['isCompleted'] ?? false) as bool
          : (map['is_completed'] ?? map['isCompleted'] ?? false) as bool,
      lastAccessedLessonId: (progressMap?['last_accessed_lesson_id'] ?? progressMap?['lastAccessedLessonId'])?.toString(),
      course: courseObj,
    );
  }

  factory EnrollmentModel.fromJson(String source) =>
      EnrollmentModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'user_id': userId,
      'enrollment_type': enrollmentType,
      'status': status,
      'price_paid': pricePaid,
      'currency': currency,
      'enrolled_at': enrolledAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'percent_complete': percentComplete,
      'is_completed': isCompleted,
      'last_accessed_lesson_id': lastAccessedLessonId,
    };
  }

  String toJson() => json.encode(toMap());
}

