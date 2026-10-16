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

  static DateTime _parseDateTime(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    if (val is String) {
      final parsed = DateTime.tryParse(val);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: (map['id'] ?? map['_id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      contentPreview: (map['content_preview'] ?? map['contentPreview'] ?? '').toString(),
      contentSections: (map['content_sections'] ?? map['contentSections']) != null
          ? List<Map<String, dynamic>>.from(map['content_sections'] ?? map['contentSections'])
          : [],
      timestamp: _parseDateTime(map['timestamp']),
    );
  }

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content_preview': contentPreview,
      'content_sections': contentSections,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toMap();
}