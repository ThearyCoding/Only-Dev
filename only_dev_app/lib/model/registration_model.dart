import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'enrollment_model.dart';

class RegistrationModel {
  final String courseId;
  final String userId;
  final String docId;
  final Timestamp timestamp;
  final bool isRegistered;
  final String categoryId;

  RegistrationModel({
    required this.courseId,
    required this.userId,
    required this.docId,
    required this.timestamp,
    required this.isRegistered,
    required this.categoryId,
  });

  static Timestamp _toTimestamp(dynamic val) {
    if (val == null) return Timestamp.now();
    if (val is Timestamp) return val;
    if (val is DateTime) return Timestamp.fromDate(val);
    if (val is String) {
      final dt = DateTime.tryParse(val);
      return dt != null ? Timestamp.fromDate(dt) : Timestamp.now();
    }
    if (val is int) {
      return Timestamp.fromMillisecondsSinceEpoch(val);
    }
    return Timestamp.now();
  }

  factory RegistrationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = (doc.data() as Map<String, dynamic>?) ?? {};
    return RegistrationModel(
      courseId: (data['courseId'] ?? '').toString(),
      userId: (data['userId'] ?? '').toString(),
      docId: doc.id,
      timestamp: _toTimestamp(data['timestamp'] ?? data['enrolledAt']),
      isRegistered: data['isRegistered'] ?? (data['status'] == 'active'),
      categoryId: (data['categoryId'] ?? '').toString(),
    );
  }

  factory RegistrationModel.fromEnrollment(EnrollmentModel enrollment) {
    return RegistrationModel(
      courseId: enrollment.courseId,
      userId: enrollment.userId,
      docId: enrollment.id,
      timestamp: Timestamp.fromDate(enrollment.enrolledAt),
      isRegistered: enrollment.isRegistered,
      categoryId: enrollment.categoryId,
    );
  }

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      courseId: (json['course_id'] ?? json['courseId'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      docId: (json['doc_id'] ?? json['docId'] ?? json['_id'] ?? json['id'] ?? '').toString(),
      timestamp: _toTimestamp(json['timestamp'] ?? json['enrolled_at'] ?? json['enrolledAt']),
      isRegistered: json['is_registered'] ?? json['isRegistered'] ?? (json['status'] == 'active'),
      categoryId: (json['category_id'] ?? json['categoryId'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'course_id': courseId,
      'user_id': userId,
      'doc_id': docId,
      'timestamp': timestamp,
      'is_registered': isRegistered,
      'category_id': categoryId,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'user_id': userId,
      'doc_id': docId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'is_registered': isRegistered,
      'category_id': categoryId,
    };
  }
}
