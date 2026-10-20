import 'dart:convert';
import 'section_model.dart';
import 'user_model.dart';

class CourseModel {
  final String id;
  final String title;
  final String imageUrl;
  final String categoryId;
  final String adminId;
  final String? createdAt;
  final String? updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final int? registerCounts;
  final double? price;
  final int? discount;
  final String? status;
  final String? description;
  final String? blurHash;

  // New modern LMS fields
  final String? slug;
  final String? level;
  final List<String>? tags;
  final double? ratingAvg;
  final int? ratingCount;
  final int? totalDurationSeconds;
  final int? totalLessons;
  final List<Section>? sections;
  final UserModel? instructor;
  final bool isEnrolled;
  final bool isRegistered;
  final String? enrollmentId;

  CourseModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.categoryId,
    required this.adminId,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.registerCounts,
    this.price,
    this.discount,
    this.status,
    this.description,
    this.blurHash,
    this.slug,
    this.level,
    this.tags,
    this.ratingAvg,
    this.ratingCount,
    this.totalDurationSeconds,
    this.totalLessons,
    this.sections,
    this.instructor,
    this.isEnrolled = false,
    this.isRegistered = false,
    this.enrollmentId,
  });

  // Modern naming aliases
  String get instructorId => adminId;
  int get enrollmentCounts => registerCounts ?? 0;
  String get thumbnailUrl => imageUrl;

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: (map['id'] ?? map['_id'] ?? '').toString(),
      title: map['title'] as String? ?? '',
      imageUrl: (map['thumbnail_url'] ?? map['thumbnailUrl'] ?? map['imageUrl'] ?? map['image_url'] ?? '').toString(),
      categoryId: (map['category_id'] ?? map['category'] ?? map['categoryId'] ?? '').toString(),
      adminId: (map['instructor_id'] is Map
              ? map['instructor_id']['_id']
              : map['instructor_id'] ?? map['instructorId'] ?? map['admin_id'] ?? map['adminId'] ?? '')
          .toString(),
      createdAt: (map['created_at'] ?? map['createdAt'] ?? map['timestamp'])?.toString(),
      updatedAt: (map['updated_at'] ?? map['updatedAt'])?.toString(),
      createdBy: (map['created_by'] ?? map['createdBy'])?.toString(),
      updatedBy: (map['updated_by'] ?? map['updatedBy'])?.toString(),
      registerCounts: (map['enrollment_counts'] ?? map['enrollmentCounts'] ?? map['register_counts'] ?? map['registerCounts']) as int? ?? 0,
      price: ((map['price'] ?? 0) as num).toDouble(),
      discount: (map['discount_percentage'] ?? map['discountPercentage'] ?? map['discount']) as int? ?? 0,
      status: map['status'] as String? ?? '',
      description: map['description'] as String? ?? '',
      blurHash: (map['blur_hash'] ?? map['blurHash']) as String? ?? '',
      slug: map['slug'] as String?,
      level: map['level'] as String?,
      tags: map['tags'] != null ? List<String>.from(map['tags'] as List) : null,
      ratingAvg: (map['rating_avg'] ?? map['ratingAvg']) != null ? ((map['rating_avg'] ?? map['ratingAvg']) as num).toDouble() : null,
      ratingCount: (map['rating_count'] ?? map['ratingCount']) as int?,
      totalDurationSeconds: (map['total_duration_seconds'] ?? map['totalDurationSeconds']) as int?,
      totalLessons: (map['total_lessons'] ?? map['totalLessons']) as int?,
      sections: (map['sections'] as List<dynamic>?)
          ?.map((x) => Section.fromMap(x as Map<String, dynamic>))
          .toList(),
      instructor: (map['instructor_id'] is Map
          ? UserModel.fromMap(map['instructor_id'] as Map<String, dynamic>)
          : (map['instructorId'] is Map
              ? UserModel.fromMap(map['instructorId'] as Map<String, dynamic>)
              : (map['instructor'] is Map
                  ? UserModel.fromMap(map['instructor'] as Map<String, dynamic>)
                  : null))),
      isEnrolled: (map['is_enrolled'] ?? map['isEnrolled'] ?? map['is_registered'] ?? map['isRegistered'] ?? false) == true,
      isRegistered: (map['is_registered'] ?? map['isRegistered'] ?? map['is_enrolled'] ?? map['isEnrolled'] ?? false) == true,
      enrollmentId: (map['enrollment_id'] ?? map['enrollmentId'])?.toString(),
    );
  }

  factory CourseModel.fromJson(String source) =>
      CourseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'thumbnail_url': imageUrl,
      'category_id': categoryId,
      'instructor_id': adminId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'enrollment_counts': registerCounts,
      'price': price,
      'discount': discount,
      'status': status,
      'description': description,
      'blur_hash': blurHash,
      'slug': slug,
      'level': level,
      'tags': tags,
      'rating_avg': ratingAvg,
      'rating_count': ratingCount,
      'total_duration_seconds': totalDurationSeconds,
      'total_lessons': totalLessons,
      'is_enrolled': isEnrolled,
      'is_registered': isRegistered,
      if (enrollmentId != null) 'enrollment_id': enrollmentId,
      if (sections != null) 'sections': sections!.map((s) => s.toMap()).toList(),
      if (instructor != null) 'instructor': instructor!.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
}
