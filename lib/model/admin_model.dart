class AdminModel {
  final String id;
  final String name;
  final String email;
  final String imageUrl;

  AdminModel(
      {required this.id,
      required this.name,
      required this.email,
      required this.imageUrl});

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['uid'] ?? "",
      name: json['fullName'] ?? "Unknown",
      email: json['email'] ?? "",
      imageUrl: json['imageUrl'] ?? "",
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
    return {'uid': id, 'fullName': name, 'email': email, 'imageUrl': imageUrl};
  }
}
