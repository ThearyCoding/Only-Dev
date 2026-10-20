class BannerModel {
  final String id;
  final String imageUrl;
  final String? createdAt;
  final String? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  BannerModel({
    required this.id,
    required this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? '').toString(),
      createdAt: (json['created_at'] ?? json['createdAt'] ?? json['timestamp'])?.toString(),
      updatedAt: (json['updated_at'] ?? json['updatedAt'])?.toString(),
      createdBy: (json['created_by'] ?? json['createdBy'])?.toString(),
      updatedBy: (json['updated_by'] ?? json['updatedBy'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }
}
