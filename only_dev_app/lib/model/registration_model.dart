import 'enrollment_model.dart';

class RegistrationModel {
  final String courseId;
  final String userId;
  final String docId;
  final String? createdAt;
  final String? updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final bool isRegistered;
  final String categoryId;

  RegistrationModel({
    required this.courseId,
    required this.userId,
    required this.docId,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    required this.isRegistered,
    required this.categoryId,
  });

  factory RegistrationModel.fromFirestore(dynamic doc) {
    Map<String, dynamic> data = {};
    if (doc != null) {
      try {
        data = (doc.data() as Map<String, dynamic>?) ?? {};
      } catch (_) {}
    }
    final docId = doc != null ? (doc.id ?? '').toString() : '';
    return RegistrationModel(
      courseId: (data['course_id'] ?? data['courseId'] ?? '').toString(),
      userId: (data['user_id'] ?? data['userId'] ?? '').toString(),
      docId: docId,
      createdAt: (data['created_at'] ?? data['createdAt'] ?? data['timestamp'] ?? data['enrolled_at'] ?? data['enrolledAt'])?.toString(),
      updatedAt: (data['updated_at'] ?? data['updatedAt'])?.toString(),
      createdBy: (data['created_by'] ?? data['createdBy'])?.toString(),
      updatedBy: (data['updated_by'] ?? data['updatedBy'])?.toString(),
      isRegistered: data['is_registered'] ?? data['isRegistered'] ?? (data['status'] == 'active'),
      categoryId: (data['category_id'] ?? data['categoryId'] ?? '').toString(),
    );
  }

  factory RegistrationModel.fromEnrollment(EnrollmentModel enrollment) {
    return RegistrationModel(
      courseId: enrollment.courseId,
      userId: enrollment.userId,
      docId: enrollment.id,
      createdAt: enrollment.createdAt ?? enrollment.enrolledAt,
      updatedAt: enrollment.updatedAt,
      createdBy: enrollment.createdBy,
      updatedBy: enrollment.updatedBy,
      isRegistered: enrollment.isRegistered,
      categoryId: enrollment.categoryId,
    );
  }

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      courseId: (json['course_id'] ?? json['courseId'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      docId: (json['doc_id'] ?? json['docId'] ?? json['_id'] ?? json['id'] ?? '').toString(),
      createdAt: (json['created_at'] ?? json['createdAt'] ?? json['timestamp'] ?? json['enrolled_at'] ?? json['enrolledAt'])?.toString(),
      updatedAt: (json['updated_at'] ?? json['updatedAt'])?.toString(),
      createdBy: (json['created_by'] ?? json['createdBy'])?.toString(),
      updatedBy: (json['updated_by'] ?? json['updatedBy'])?.toString(),
      isRegistered: json['is_registered'] ?? json['isRegistered'] ?? (json['status'] == 'active'),
      categoryId: (json['category_id'] ?? json['categoryId'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'course_id': courseId,
      'user_id': userId,
      'doc_id': docId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'is_registered': isRegistered,
      'category_id': categoryId,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}
