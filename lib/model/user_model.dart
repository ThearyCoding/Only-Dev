import '../export/export.dart';

class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String fullName;
  final String photoURL;
  final String email;
  final int gender;
  final DateTime dob;
  final String bgColor;
  final String? bio;
  final String backgroundColor;
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
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      fullName: map['fullName'] ?? '',
      photoURL: map['photoURL'] ?? '',
      email: map['email'] ?? '',
      gender: map['gender'] ?? 0,
      dob: (map['dob'] as Timestamp).toDate(),
      bgColor: map['bgColor'] ?? 'FFFFFFFF', 
      backgroundColor: map['backgroundColor'] ?? '',
      bio: map['bio'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'photoURL': photoURL,
      'email': email,
      'gender': gender,
      'dob': dob,
      'bgColor': bgColor,
      'backgroundColor': backgroundColor,
      'bio': bio,
    };
  }
}
