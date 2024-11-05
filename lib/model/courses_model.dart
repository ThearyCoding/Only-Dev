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
  final bool? status;
  final String? description;

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
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'adminId': adminId,
      'timestamp': timestamp?.millisecondsSinceEpoch,
      'registerCounts': registerCounts,
      'price': price,
      'discount': discount,
      'status': status,
      'description': description
    };
  }

  factory CourseModel.fromMap(Map<String, dynamic> map) {
  return CourseModel(
    id: map['id'] as String,
    title: map['title'] as String,
    imageUrl: map['imageUrl'] as String,
    categoryId: map['categoryId'] as String,
    adminId: map['adminId'] as String,
    timestamp: map['timestamp'] != null
        ? (map['timestamp'] as Timestamp).toDate()
        : null,
    registerCounts: map['registerCounts'] as int?,
    price: (map['price'] ?? 0).toDouble(),
    discount: map['discount'] as int?,
    status: map['status'] as bool?,
    description: map['description'] as String?,
  );
}


  factory CourseModel.fromJson(String source) =>
      CourseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  factory CourseModel.fromFirestore(QueryDocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CourseModel(
      id: doc.id,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      categoryId: data['categoryId'] ?? '',
      adminId: data['adminId'] ?? '',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : null,
      registerCounts: data['registerCounts'] as int?,
      price: data['price'] as double?,
      discount: data['discount'] as int?,
      status: data['status'] as bool?,
       description: data['description'] as String?,
    );
  }

    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'adminId': adminId,
      'timestamp': timestamp,
      'registerCounts': registerCounts,
      'price': price,
      'discount': discount,
      'status': status,
       'description': description
    };
  }

}
