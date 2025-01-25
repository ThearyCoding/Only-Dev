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
        id: json['id'],
        title: json['title'],
        imageUrl: json['imageUrl'],
        blurHash: json['blurHash'] as String);
  }
}
