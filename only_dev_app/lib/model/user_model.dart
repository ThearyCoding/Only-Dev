import 'dart:convert';

class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String fullName;
  final String photoURL;
  final String email;
  final int gender;
  final String dob;
  final String bgColor;
  final String? bio;
  final String backgroundColor;

  // New unified RBAC & Profile fields
  final String role;
  final List<String> customPermissions;
  final String? headline;
  final String? createdAt;
  final String? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.photoURL,
    required this.email,
    required this.gender,
    required this.dob,
    required this.bgColor,
    required this.backgroundColor,
    this.bio,
    this.role = 'STUDENT',
    this.customPermissions = const [],
    this.headline,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  bool get isAdmin => role.toUpperCase() == 'ADMIN' || role.toUpperCase() == 'SUPER_ADMIN';
  bool get isInstructor => role.toUpperCase() == 'INSTRUCTOR' || isAdmin;

  // Compatibility getters replacing AdminModel
  String get id => uid;
  String get name => fullName;
  String get imageUrl => photoURL;
  String? get avatarUrl => photoURL.isNotEmpty ? photoURL : null;

  factory UserModel.empty() {
    return UserModel(
      uid: '',
      firstName: '',
      lastName: '',
      fullName: 'Unknown',
      photoURL: '',
      email: '',
      gender: 0,
      dob: '',
      bgColor: 'FFFFFFFF',
      backgroundColor: '',
      role: 'STUDENT',
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final rawName = (map['full_name'] ?? map['fullName'] ?? map['name'] ?? '').toString();
    String fName = (map['first_name'] ?? map['firstName'] ?? '').toString();
    String lName = (map['last_name'] ?? map['lastName'] ?? '').toString();

    if (fName.isEmpty && lName.isEmpty && rawName.isNotEmpty) {
      final parts = rawName.split(' ');
      fName = parts.first;
      lName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    return UserModel(
      uid: (map['id'] ?? map['_id'] ?? map['uid'] ?? '').toString(),
      firstName: fName,
      lastName: lName,
      fullName: rawName.isNotEmpty ? rawName : '$fName $lName'.trim(),
      photoURL: (map['photo_url'] ?? map['avatar_url'] ?? map['imageUrl'] ?? map['image_url'] ?? map['photoURL'] ?? map['avatarUrl'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      gender: (map['gender'] as int?) ?? 0,
      dob: (map['dob'] ?? map['date_of_birth'] ?? '').toString(),
      bgColor: (map['bg_color'] ?? map['bgColor'] ?? 'FFFFFFFF').toString(),
      backgroundColor: (map['background_color'] ?? map['backgroundColor'] ?? '').toString(),
      bio: map['bio'] as String?,
      role: (map['role'] ?? 'STUDENT').toString().toUpperCase(),
      customPermissions: (map['custom_permissions'] ?? map['customPermissions']) != null
          ? List<String>.from((map['custom_permissions'] ?? map['customPermissions']) as List)
          : const [],
      headline: map['headline'] as String?,
      createdAt: (map['created_at'] ?? map['createdAt'] ?? map['timestamp'])?.toString(),
      updatedAt: (map['updated_at'] ?? map['updatedAt'])?.toString(),
      createdBy: (map['created_by'] ?? map['createdBy'])?.toString(),
      updatedBy: (map['updated_by'] ?? map['updatedBy'])?.toString(),
    );
  }

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() {
    return {
      'id': uid,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'photo_url': photoURL,
      'email': email,
      'gender': gender,
      'dob': dob,
      'bg_color': bgColor,
      'background_color': backgroundColor,
      'bio': bio,
      'role': role,
      'custom_permissions': customPermissions,
      'headline': headline,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  String toJson() => json.encode(toMap());
}
