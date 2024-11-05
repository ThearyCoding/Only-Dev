import 'dart:developer';
import 'package:e_leaningapp/di/dependency_injection.dart';
import 'package:flutter/foundation.dart';
import '../../export/export.dart';

class FirebaseService {
  final CollectionReference categoriesCollection =
      FirebaseFirestore.instance.collection('categories');
  final CollectionReference coursesCollection =
      FirebaseFirestore.instance.collection('courses');
  final CollectionReference adminsCollection =
      FirebaseFirestore.instance.collection('admins');
  final FirebaseFirestore _firestore = locator<FirebaseFirestore>();

  final FirebaseStorage storage = locator<FirebaseStorage>();

  
  

  Future<void> updateLectureViews(String categoryId, String courseId,
      String sectionId, String lectureId) async {
    final sectionRef = _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('courses')
        .doc(courseId)
        .collection('sections')
        .doc(sectionId);

    try {
      // Fetch the section document
      final sectionSnapshot = await sectionRef.get();
      final sectionData = sectionSnapshot.data() as Map<String, dynamic>;

      // Get the list of lectures from the section document
      final sectionLectures =
          List<Map<String, dynamic>>.from(sectionData['lectures'] ?? []);

      // Find the index of the lecture to update
      final lectureIndex =
          sectionLectures.indexWhere((lecture) => lecture['id'] == lectureId);

      // If the lecture exists, update its 'views' field
      if (lectureIndex != -1) {
        // Update the views field for the specific lecture
        sectionLectures[lectureIndex]['views'] =
            (sectionLectures[lectureIndex]['views'] ?? 0) + 1;

        // Update the section document with the modified lectures list
        await sectionRef.update({
          'lectures': sectionLectures,
        });
      } else {
        throw Exception('Lecture not found in section');
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error updating lecture views: $e');
      }
    }
  }

  Future<Map<String, dynamic>> getWatchedLectures() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return {};
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('watchedVideos')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      log('Error fetching watched lectures: $e');
      return {};
    }
  }

 
  Future<void> updateUserProgress(String userId, String categoryId,
      String courseId, String sectionId) async {
    try {
      await _firestore
          .collection('user_progress')
          .doc(courseId)
          .collection('users')
          .doc(userId)
          .set({
        'categoryId': categoryId,
        'courseId': courseId,
        'section': {
          sectionId: true,
        },
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        log('Error updating user progress: $e');
      }
    }
  }

  Future<Map<String, dynamic>?> getUserProgress(
      String userId, String courseId) async {
    try {
      // Retrieve the user's progress for the specified course from Firestore
      DocumentSnapshot<Map<String, dynamic>> userProgressSnapshot =
          await _firestore
              .collection('user_progress')
              .doc(courseId)
              .collection('users')
              .doc(userId)
              .get();

      if (userProgressSnapshot.exists) {
        return userProgressSnapshot.data();
      } else {
        if (kDebugMode) {
          log('User progress not found for course: $courseId');
        }
        return null;
      }
    } catch (e) {
      log('Error getting user progress: $e');

      return null;
    }
  }


  Stream<List<BannerModel>> fetchBanners() {
    return _firestore.collection('banners').snapshots().map((query) {
      return query.docs.map((doc) {
        return BannerModel.fromJson(doc.data());
      }).toList();
    });
  }
}
