class AdminModel {
  final String id;
  final String name;
  final String email;
  final String imageUrl;

  AdminModel({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: (json['id'] ?? json['uid'] ?? json['_id'] ?? '').toString(),
      name: (json['full_name'] ?? json['fullName'] ?? json['name'] ?? 'Unknown').toString(),
      email: (json['email'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? '').toString(),
    );
  }

  factory AdminModel.empty() {
    return AdminModel(
      id: '',
      name: 'Unknown',
      email: '',
      imageUrl: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': name,
      'email': email,
      'image_url': imageUrl,
    };
  }
}
