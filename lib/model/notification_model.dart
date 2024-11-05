import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_leaningapp/model/post_model.dart';

class NotificationModel {
  final String registerId;
  final String title;
  final String message;
  final DateTime timestamp;
  final String courseId;
  final String id;
  final bool isRead;
  final String type;
  final String categoryId;
  final String? postId;
  final PostModel? post;
  NotificationModel({
    required this.registerId,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.courseId,
    required this.id,
    required this.isRead,
    required this.type,
    required this.categoryId,
    this.postId,
    this.post,
  });

  NotificationModel copyWith({
    String? registerId,
    String? title,
    String? message,
    DateTime? timestamp,
    String? courseId,
    String? id,
    bool? isRead,
    String? type,
    String? categoryId,
  }) {
    return NotificationModel(
      registerId: registerId ?? this.registerId,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      courseId: courseId ?? this.courseId,
      id: id ?? this.id,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'registerId': registerId,
      'title': title,
      'message': message,
      'timestamp': timestamp,
      'courseId': courseId,
      'id': id,
      'isRead': isRead,
      'type': type,
      'categoryId': categoryId,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      registerId: map['registerId'] as String? ?? '',
      title: map['title'] as String? ?? 'No Title',
      message: map['message'] as String? ?? 'No Message',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      courseId: map['courseId'] as String? ?? '',
      id: map['id'] as String? ?? '',
      isRead: map['isRead'] as bool? ?? false,
      type: map['type'] as String? ?? 'general',
      categoryId: map['categoryId'] as String? ?? '',
      postId: map['postId'] as String?,
      post: map['post'] != null ? PostModel.fromMap(map['post']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NotificationModel(registerId: $registerId, title: $title, message: $message, timestamp: $timestamp, courseId: $courseId, id: $id, isRead: $isRead, type: $type , categoryId: $categoryId)';
  }

  @override
  bool operator ==(covariant NotificationModel other) {
    if (identical(this, other)) return true;

    return other.registerId == registerId &&
        other.title == title &&
        other.message == message &&
        other.timestamp == timestamp &&
        other.courseId == courseId &&
        other.id == id &&
        other.isRead == isRead &&
        other.type == type &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    return registerId.hashCode ^
        title.hashCode ^
        message.hashCode ^
        timestamp.hashCode ^
        courseId.hashCode ^
        id.hashCode ^
        isRead.hashCode ^
        type.hashCode ^
        categoryId.hashCode;
  }
}
