import 'dart:convert';

class CourseModel {
  final String id;
  final String title;
  final String imageUrl;
  final String categoryId;
  final String adminId;
  final DateTime? timestamp;
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

  CourseModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.categoryId,
    required this.adminId,
    this.timestamp,
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
  });

  // Modern naming aliases
  String get instructorId => adminId;
  int get enrollmentCounts => registerCounts ?? 0;
  String get thumbnailUrl => imageUrl;

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    // Backward compatibility for Firestore Timestamp without hard dependency
    try {
      final dynamic dyn = value;
      return dyn.toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }

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
      timestamp: _parseDateTime(map['created_at'] ?? map['createdAt'] ?? map['timestamp']),
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
      'created_at': timestamp?.toIso8601String(),
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
    };
  }

  String toJson() => json.encode(toMap());
}
