import 'package:cloud_firestore/cloud_firestore.dart';

class Lecture {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final DateTime timestamp;
  final String sectionId;
  final String thumbnailUrl;
  final int videoDuration;
  final num views;

  Lecture({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.timestamp,
    required this.sectionId,
    required this.thumbnailUrl,
    required this.videoDuration,
    required this.views
  });

  factory Lecture.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = (snapshot.data() as Map<String, dynamic>?) ?? {};
    return Lecture.fromMap({'id': snapshot.id, ...data});
  }

  factory Lecture.empty() {
    return Lecture(
      id: '',
      title: '',
      description: '',
      videoDuration: 0,
      videoUrl: '',
      timestamp: DateTime.now(),
      sectionId: '',
      thumbnailUrl: '',
      views: 0,
    );
  }

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

  factory Lecture.fromMap(Map<String, dynamic> json) {
    return Lecture(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      videoUrl: (json['video_url'] ?? json['videoUrl'] ?? '').toString(),
      timestamp: _parseDateTime(json['timestamp']),
      sectionId: (json['section_id'] ?? json['sectionId'] ?? '').toString(),
      thumbnailUrl: (json['thumbnail_url'] ?? json['thumbnailUrl'] ?? '').toString(),
      videoDuration: (json['video_duration'] ?? json['videoDuration'] ?? 0) is num
          ? (json['video_duration'] ?? json['videoDuration'] ?? 0).toInt()
          : int.tryParse((json['video_duration'] ?? json['videoDuration'] ?? '0').toString()) ?? 0,
      views: (json['views'] ?? 0) as num,
    );
  }

  factory Lecture.fromJson(Map<String, dynamic> json) => Lecture.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'timestamp': timestamp.toIso8601String(),
      'section_id': sectionId,
      'thumbnail_url': thumbnailUrl,
      'video_duration': videoDuration,
      'views': views,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}
