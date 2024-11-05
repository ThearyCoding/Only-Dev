import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String title;
  final String contentPreview;
  final List<Map<String, dynamic>> contentSections;
  final DateTime timestamp;

  PostModel({
    required this.id,
    required this.title,
    required this.contentPreview,
    required this.contentSections,
    required this.timestamp,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'],
      title: map['title'],
      contentPreview: map['contentPreview'],
      contentSections: List<Map<String, dynamic>>.from(map['contentSections']),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}