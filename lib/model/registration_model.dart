import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationModel {
  final String courseId;
  final String userId;
  final String docId;
  final Timestamp timestamp;
  final bool isRegistered;
  final String categoryId;

  RegistrationModel({
    required this.courseId,
    required this.userId,
    required this.docId,
    required this.timestamp,
    required this.isRegistered,
    required this.categoryId,
  });

  factory RegistrationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RegistrationModel(
      courseId: data['courseId'] ?? '',
      userId: data['userId'] ?? '',
      docId: doc.id,
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isRegistered: data['isRegistered'] ?? false,
      categoryId: data['categoryId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'userId': userId,
      'docId': docId,
      'timestamp': timestamp,
    };
  }

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      courseId: json['courseId'],
      userId: json['userId'],
      docId: json['docId'],
      timestamp: Timestamp.fromMillisecondsSinceEpoch(json['timestamp']),
      isRegistered: json['isRegistered'],
      categoryId: json['categoryId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'userId': userId,
      'docId': docId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRegistered': isRegistered
    };
  }
}
