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
  factory AdminModel.fromMap(Map<String,dynamic> map){
    return AdminModel(
       id: map['uid'] ?? "",
      name: map['fullName'] ?? "Unknown",
      email: map['email'] ?? "",
      imageUrl: map['imageUrl'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {'uid': id, 'fullName': name, 'email': email, 'imageUrl': imageUrl};
  }
}
