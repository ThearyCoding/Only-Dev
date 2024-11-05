import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_leaningapp/model/registration_model.dart';
import 'package:flutter/foundation.dart';

class FirebaseApiRegistration {
  final CollectionReference _courseRegistrationCollection =
      FirebaseFirestore.instance.collection('courseRegistrations');

  Future<void> registerCourse(
      {required String courseId, required String userId,required String categoryId , required String id}) async {
    try {
      await _courseRegistrationCollection.doc(id).set({
         'courseId': courseId,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'isRegistered': true,
        'docId': id,
        'categoryId': categoryId,
      });
      await countRegisterCourse(courseId);
    } catch (e) {
      if (kDebugMode) {
        print('Error registering course: $e');
      }
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> countRegisterCourse(String courseId) async {
    try {
      final querySnapshot = await _firestore
          .collectionGroup('courses')
          .where('id', isEqualTo: courseId)
          .get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.update(
          {'registerCounts': FieldValue.increment(1)},
        ); // Ensure the field is created if it doesn't exist
      }
    } catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
    }
  }

  Future<List<RegistrationModel>> getUserRegisteredCourses(
      String userId) async {
    try {
      final querySnapshot = await _courseRegistrationCollection
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RegistrationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching registered courses: $e');
      }
      return [];
    }
  }

  Future<bool> isUserRegisteredForCourse({
    required String userId,
    required String courseId,
  }) async {
    try {
      final querySnapshot = await _courseRegistrationCollection
          .where('userId', isEqualTo: userId)
          .where('courseId', isEqualTo: courseId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking registration: $e');
      }
      return false;
    }
  }

  Future<void> checkAndRegisterUser({
    required String categoryId,
    required String userId,
    required String courseId,
    required String id
  }) async {
    bool isRegistered = await isUserRegisteredForCourse(
      userId: userId,
      courseId: courseId,
    );

    if (isRegistered) {
      if (kDebugMode) {
        print('User is already registered for this course.');
      }
    } else {
      await registerCourse(courseId: courseId, userId: userId,categoryId: categoryId, id: id);
      if (kDebugMode) {
        print('User has been successfully registered for the course.');
      }
    }
  }
}
