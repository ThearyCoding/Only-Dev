import 'package:cloud_firestore/cloud_firestore.dart';
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
  });
  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      categoryId: map['categoryId'] as String? ?? '',
      adminId: map['adminId'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : null,
      registerCounts: map['registerCounts'] as int?,
      price: (map['price'] ?? 0).toDouble(),
      discount: map['discount'] as int?,
      status: map['status'] as String? ?? '',
      description: map['description'] as String? ?? '',
      blurHash: map['blurHash'] as String? ?? '',
    );
  }

  factory CourseModel.fromJson(String source) =>
      CourseModel.fromMap(json.decode(source) as Map<String, dynamic>);

}
