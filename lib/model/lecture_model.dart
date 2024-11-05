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
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Lecture(
      id: snapshot.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      sectionId: data['sectionId'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      videoDuration: data['videoDuration'] ?? 0.0,
      views: data['views'] ?? 0,
    );
  }

  factory Lecture.fromMap(Map<String, dynamic> json) {
    return Lecture(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['videoUrl'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      sectionId: json['sectionId'],
      thumbnailUrl: json['thumbnailUrl'],
      videoDuration: json['videoDuration'],
      views: json['views'] ?? 0,
    );
  }

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['videoUrl'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      sectionId: json['sectionId'],
      thumbnailUrl: json['thumbnailUrl'],
      videoDuration: json['videoDuration'],
      views: json['views'] ?? 0
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'sectionId': sectionId,
      'thumbnailUrl': thumbnailUrl,
      'videoDuration': videoDuration,
      'views': views
    };
  }
}
