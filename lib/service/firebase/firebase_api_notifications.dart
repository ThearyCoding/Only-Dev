import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_leaningapp/model/notification_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../di/dependency_injection.dart';
import '../../model/courses_model.dart';

class FirebaseApiNotifications {
  final FirebaseFirestore _firestore = locator<FirebaseFirestore>();
 final User? user = locator<FirebaseAuth>().currentUser;
  // Fetch unread notifications count (where isRead is false)
  Stream<int> getUnreadCount() {
    try {
      if (user == null) {
        return Stream.value(0); // Return 0 if the user is null
      }
      return _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('notifications')
          .where('isRead', isEqualTo: false) // Filter by unread notifications
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (error) {
      return Stream.value(0); // Return 0 if the user is null
    }
  }

  Future<void> saveNotification(
      NotificationModel notification, String userId) async {
    try {
      if (user == null) {
        return;
      }
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());
    } catch (error) {
      log('Error while save notification : $error');
    }
  }

  // Fetch unread notifications (where isRead is false)
  Future<QuerySnapshot> getUnreadNotifications() {
    try {
      if (user == null) {
        throw Exception(
            'User is not logged in.'); // Handle the case where user is null
      }
      return _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('notifications')
          .where('isRead', isEqualTo: false) // Filter by unread notifications
          .get();
    } catch (error) {
      throw Exception('User is not logged in.');
    }
  }

  Future<List<CourseModel>> fetchUserNotificationsAndCourses(
      String userId) async {
    try {
      // Fetch notifications for the specific user
      final notificationsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .get();

      // Extract notifications data
      final notifications =
          notificationsSnapshot.docs.map((doc) => doc.data()).toList();

      // Extract course IDs from the notifications
      final courseIds = notifications
          .map((notification) => notification['courseId'] as String?)
          .where((courseId) => courseId != null)
          .toSet();

      final courses = <CourseModel>[];

      // Fetch each course document based on the course IDs
      for (final courseId in courseIds) {
        if (courseId == null) continue; // Skip if courseId is null

        final courseQuerySnapshot = await FirebaseFirestore.instance
            .collectionGroup('courses')
            .where('id', isEqualTo: courseId)
            .get();

        // Loop through the results in case there are multiple matches
        for (var courseDoc in courseQuerySnapshot.docs) {
          if (courseDoc.exists) {
            final courseData = courseDoc.data();
            final course = CourseModel.fromMap(courseData);
            courses.add(course);
          }
        }
      }
      // Return the list of courses
      return courses;
    } catch (error) {
      log("Error while fetching notifications: $error");
      // Return an empty list if an error occurs
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> fetchNotificationsForUser(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true) // Order by most recent
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> markAsReadForUsersWithToken(
      String notificationId, String postId) async {
    try {
      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();

      // Iterate over each user
      for (final userDoc in usersSnapshot.docs) {
        // Check if the user document contains 'fcmToken' field
        if (userDoc.data().containsKey('fcmToken')) {
          final userId = userDoc.id;

          // Update the specific notification for each user
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('notifications')
              .doc(notificationId)
              .set({
            'timestamp': Timestamp.now(),
            'id': notificationId,
            'type': 'announcement',
            'isRead': false,
            'postId': postId,
          });
        }
      }

      log('Notification marked as read for users with fcmToken');
    } catch (e) {
      log('Error marking notification as read: $e');
    }
  }
}
