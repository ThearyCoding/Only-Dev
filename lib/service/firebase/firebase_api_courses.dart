import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/admin_model.dart';
import '../../model/courses_model.dart';

class FirebaseApiCourses {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CourseModel?> fetchCourseById(String courseId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collectionGroup('courses')
          .where('courseId', isEqualTo: courseId)
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.first);

      if (doc.exists) {
        return CourseModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      log('Error fetching course by ID: $e');
      return null;
    }
  }

  Stream<List<CourseModel>> fetchCourses() {
    return FirebaseFirestore.instance
        .collectionGroup('courses')
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CourseModel.fromMap(doc.data()))
          .toList();
    });
  }

  Future<Map<String, dynamic>?> fetchCourseAndAdminById({
    required String categoryId,
    required String courseId,
  }) async {
    try {
      // Fetch the course document
      DocumentSnapshot courseDoc = await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('courses')
          .where('id', isEqualTo: courseId)
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.first);

      if (courseDoc != null && courseDoc.exists) {
        // Parse course data
        CourseModel course =
            CourseModel.fromMap(courseDoc.data() as Map<String, dynamic>);

        // Fetch the associated admin using the adminId from the course
        String adminId = course.adminId;
        DocumentSnapshot adminDoc =
            await _firestore.collection('admins').doc(adminId).get();

        AdminModel? admin;
        if (adminDoc.exists) {
          // Parse admin data
          admin = AdminModel.fromMap(adminDoc.data() as Map<String, dynamic>);
        }

        // Return the course and admin as a Map
        return {
          'course': course,
          'admin': admin,
        };
      } else {
        // Return null if no course is found
        return null;
      }
    } catch (e) {
      log('Error fetching course and admin: $e');
      return null;
    }
  }
}
