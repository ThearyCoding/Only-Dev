import 'dart:convert';
import 'post_model.dart';

class NotificationModel {
  final String registerId;
  final String title;
  final String message;
  final String? createdAt;
  final String? updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final String courseId;
  final String id;
  final bool isRead;
  final bool isDetailSeen;
  final String type;
  final String categoryId;
  final String? postId;
  final PostModel? post;

  NotificationModel({
    required this.registerId,
    required this.title,
    required this.message,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    required this.courseId,
    required this.id,
    required this.isRead,
    this.isDetailSeen = false,
    required this.type,
    required this.categoryId,
    this.postId,
    this.post,
  });

  NotificationModel copyWith({
    String? registerId,
    String? title,
    String? message,
    String? createdAt,
    String? updatedAt,
    String? createdBy,
    String? updatedBy,
    String? courseId,
    String? id,
    bool? isRead,
    bool? isDetailSeen, // Added here
    String? type,
    String? categoryId,
    String? postId,
    PostModel? post,
  }) {
    return NotificationModel(
      registerId: registerId ?? this.registerId,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      courseId: courseId ?? this.courseId,
      id: id ?? this.id,
      isRead: isRead ?? this.isRead,
      isDetailSeen: isDetailSeen ?? this.isDetailSeen, 
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      postId: postId ?? this.postId,
      post: post ?? this.post,
    );
  }

  factory NotificationModel.empty() {
    return NotificationModel(
      id: '',
      registerId: '',
      title: 'Unknown',
      message: '',
      createdAt: '',
      updatedAt: '',
      createdBy: '',
      updatedBy: '',
      courseId: '',
      isRead: false,
      isDetailSeen: false,
      type: '',
      categoryId: '',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'register_id': registerId,
      'title': title,
      'message': message,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'course_id': courseId,
      'id': id,
      'is_read': isRead,
      'is_detail_seen': isDetailSeen,
      'type': type,
      'category_id': categoryId,
      'post_id': postId,
      'post': post?.toMap(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      registerId: (map['register_id'] ?? map['registerId'] ?? '').toString(),
      title: (map['title'] ?? 'No Title').toString(),
      message: (map['message'] ?? 'No Message').toString(),
      createdAt: (map['created_at'] ?? map['createdAt'] ?? map['timestamp'])?.toString(),
      updatedAt: (map['updated_at'] ?? map['updatedAt'])?.toString(),
      createdBy: (map['created_by'] ?? map['createdBy'])?.toString(),
      updatedBy: (map['updated_by'] ?? map['updatedBy'])?.toString(),
      courseId: (map['course_id'] ?? map['courseId'] ?? '').toString(),
      id: (map['id'] ?? map['_id'] ?? '').toString(),
      isRead: map['is_read'] ?? map['isRead'] ?? false,
      isDetailSeen: map['is_detail_seen'] ?? map['isDetailSeen'] ?? false, 
      type: (map['type'] ?? 'general').toString(),
      categoryId: (map['category_id'] ?? map['categoryId'] ?? '').toString(),
      postId: (map['post_id'] ?? map['postId'])?.toString(),
      post: map['post'] != null && map['post'] is Map<String, dynamic>
          ? PostModel.fromMap(map['post'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NotificationModel(registerId: $registerId, title: $title, message: $message, createdAt: $createdAt, courseId: $courseId, id: $id, isRead: $isRead, isDetailSeen: $isDetailSeen, type: $type , categoryId: $categoryId)';
  }

  @override
  bool operator ==(covariant NotificationModel other) {
    if (identical(this, other)) return true;

    return other.registerId == registerId &&
        other.title == title &&
        other.message == message &&
        other.createdAt == createdAt &&
        other.courseId == courseId &&
        other.id == id &&
        other.isRead == isRead &&
        other.isDetailSeen == isDetailSeen &&
        other.type == type &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    return registerId.hashCode ^
        title.hashCode ^
        message.hashCode ^
        createdAt.hashCode ^
        courseId.hashCode ^
        id.hashCode ^
        isRead.hashCode ^
        isDetailSeen.hashCode ^ 
        type.hashCode ^
        categoryId.hashCode;
  }
}
