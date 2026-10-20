class PostModel {
  final String id;
  final String title;
  final String contentPreview;
  final List<Map<String, dynamic>> contentSections;
  final String? createdAt;
  final String? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  PostModel({
    required this.id,
    required this.title,
    required this.contentPreview,
    required this.contentSections,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: (map['id'] ?? map['_id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      contentPreview: (map['content_preview'] ?? map['contentPreview'] ?? '').toString(),
      contentSections: (map['content_sections'] ?? map['contentSections']) != null
          ? List<Map<String, dynamic>>.from(map['content_sections'] ?? map['contentSections'])
          : [],
      createdAt: (map['created_at'] ?? map['createdAt'] ?? map['timestamp'])?.toString(),
      updatedAt: (map['updated_at'] ?? map['updatedAt'])?.toString(),
      createdBy: (map['created_by'] ?? map['createdBy'])?.toString(),
      updatedBy: (map['updated_by'] ?? map['updatedBy'])?.toString(),
    );
  }

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content_preview': contentPreview,
      'content_sections': contentSections,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}