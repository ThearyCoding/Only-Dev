import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String title;
  final String imageUrl;

  CategoryModel({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
    };
  }

  factory CategoryModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return CategoryModel(
      id: data['id'],
      title: data['title'],
      imageUrl: data['imageUrl'],
    );
  }

  String toJsonString() {
    return jsonEncode(toMap());
  }

  factory CategoryModel.fromJsonString(String jsonString) {
    Map<String, dynamic> map = jsonDecode(jsonString);
    return CategoryModel(
      id: map['id'],
      title: map['title'],
      imageUrl: map['imageUrl'],
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
    );
  }
}