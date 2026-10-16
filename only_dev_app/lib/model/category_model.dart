class CategoryModel {
  final String id;
  final String title;
  final String imageUrl;
  final String? blurHash;

  CategoryModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.blurHash,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? '').toString(),
      blurHash: (json['blur_hash'] ?? json['blurHash'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'blur_hash': blurHash,
    };
  }
}
