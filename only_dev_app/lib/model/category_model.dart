class CategoryModel {
  final String id;
  final String title;
  final String imageUrl;
  final String? blurHash;
  final String? createdAt;
  final String? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  CategoryModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.blurHash,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? '').toString(),
      blurHash: (json['blur_hash'] ?? json['blurHash'])?.toString(),
      createdAt: (json['created_at'] ?? json['createdAt'] ?? json['timestamp'])?.toString(),
      updatedAt: (json['updated_at'] ?? json['updatedAt'])?.toString(),
      createdBy: (json['created_by'] ?? json['createdBy'])?.toString(),
      updatedBy: (json['updated_by'] ?? json['updatedBy'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'blur_hash': blurHash,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }
}
