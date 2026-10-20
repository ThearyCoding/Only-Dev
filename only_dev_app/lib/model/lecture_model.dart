class Lecture {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String sectionId;
  final String thumbnailUrl;
  final int videoDuration;
  final num views;
  final String? createdAt;
  final String? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  Lecture({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.sectionId,
    required this.thumbnailUrl,
    required this.videoDuration,
    required this.views,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory Lecture.fromSnapshot(dynamic snapshot) {
    Map<String, dynamic> data = {};
    if (snapshot != null) {
      try {
        data = (snapshot.data() as Map<String, dynamic>?) ?? {};
      } catch (_) {}
    }
    final docId = snapshot != null ? snapshot.id ?? '' : '';
    return Lecture.fromMap({'id': docId, ...data});
  }

  factory Lecture.empty() {
    return Lecture(
      id: '',
      title: '',
      description: '',
      videoDuration: 0,
      videoUrl: '',
      sectionId: '',
      thumbnailUrl: '',
      views: 0,
      createdAt: '',
      updatedAt: '',
      createdBy: '',
      updatedBy: '',
    );
  }

  factory Lecture.fromMap(Map<String, dynamic> json) {
    String vUrl = (json['video_url'] ?? json['videoUrl'] ?? '').toString();
    int vDuration = 0;
    String tUrl = (json['thumbnail_url'] ?? json['thumbnailUrl'] ?? '').toString();

    if (json['video'] is Map) {
      final vMap = json['video'] as Map<String, dynamic>;
      if (vUrl.isEmpty) {
        vUrl = (vMap['raw_url'] ?? vMap['rawUrl'] ?? vMap['hls_url'] ?? vMap['hlsUrl'] ?? '').toString();
      }
      if (tUrl.isEmpty) {
        tUrl = (vMap['thumbnail_url'] ?? vMap['thumbnailUrl'] ?? '').toString();
      }
      final dur = vMap['duration_seconds'] ?? vMap['durationSeconds'];
      if (dur != null) {
        vDuration = dur is num ? dur.toInt() : (int.tryParse(dur.toString()) ?? 0);
      }
    }
    if (vDuration == 0) {
      final dur = json['video_duration'] ?? json['videoDuration'];
      if (dur != null) {
        vDuration = dur is num ? dur.toInt() : (int.tryParse(dur.toString()) ?? 0);
      }
    }

    return Lecture(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      videoUrl: vUrl,
      sectionId: (json['section_id'] ?? json['sectionId'] ?? '').toString(),
      thumbnailUrl: tUrl,
      videoDuration: vDuration,
      views: (json['views'] ?? 0) as num,
      createdAt: (json['created_at'] ?? json['createdAt'] ?? json['timestamp'])?.toString(),
      updatedAt: (json['updated_at'] ?? json['updatedAt'])?.toString(),
      createdBy: (json['created_by'] ?? json['createdBy'])?.toString(),
      updatedBy: (json['updated_by'] ?? json['updatedBy'])?.toString(),
    );
  }

  factory Lecture.fromJson(Map<String, dynamic> json) => Lecture.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'section_id': sectionId,
      'thumbnail_url': thumbnailUrl,
      'video_duration': videoDuration,
      'views': views,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}
