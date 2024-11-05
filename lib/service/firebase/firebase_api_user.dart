import 'dart:developer';
import 'package:e_leaningapp/di/dependency_injection.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../export/curriculum_export.dart';
import '../../utils/show_error_utils.dart';

class UserService {
  final FirebaseFirestore _firestore = locator<FirebaseFirestore>();
  final User? user = locator<FirebaseAuth>().currentUser;
  Future<String?> getPhotoUrlFromFirestore(String uid) async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        // Assuming 'photoURL' is a field in the document
        String? photoURL = docSnapshot['photoURL'];
        return photoURL;
      } else {
        log('No document found for the provided UID: $uid');
        return null;
      }
    } catch (e) {
      log('Error fetching photoURL: $e');
      return null;
    }
  }

  Future<void> saveTokenToDatabase() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    }
  }

  Future<Map<String, dynamic>> getWatchedLectures() async {
    if (user == null) {
      return {};
    }

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('watchedVideos').doc(user!.uid).get();

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

  Future<void> updateViewCounts(String categoryId, String courseId,
      String sectionId, String lectureId) async {
    if (user == null) {
      log('User not logged in');
      return;
    }

    try {
      // Check if the user has watched any video before
      DocumentSnapshot userDoc =
          await _firestore.collection('watchedVideos').doc(user!.uid).get();

      // Check if the userDoc exists and contains the courseId and sectionId fields
      bool hasWatched = userDoc.exists &&
          (userDoc.data() as Map<String, dynamic>).containsKey(courseId) &&
          (userDoc.data() as Map<String, dynamic>)[courseId]
              .containsKey(sectionId) &&
          (userDoc.data() as Map<String, dynamic>)[courseId][sectionId]
              .containsKey(lectureId);

      if (!hasWatched) {
        // If the user has not watched this video before, update the view count
        await updateLectureViews(categoryId, courseId, sectionId, lectureId);

        // Mark the video as watched for the user
        await _firestore.collection('watchedVideos').doc(user!.uid).set({
          courseId: {
            sectionId: {
              lectureId: true,
            },
          },
        }, SetOptions(merge: true)); // Merge the new field with existing fields
        showSnackbar('You have completed this video!');
      }
    } catch (e) {
      log('Error updating view counts: $e');
    }
  }

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
      log('Error updating lecture views: $e');
    }
  }

  Future<int> getTotalLectures(String categoryId, String courseId) async {
    int totalLectures = 0;
    try {
      QuerySnapshot sectionsSnapshot = await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('courses')
          .doc(courseId)
          .collection('sections')
          .get();

      for (var sectionDoc in sectionsSnapshot.docs) {
        Map<String, dynamic> sectionData =
            sectionDoc.data() as Map<String, dynamic>;
        totalLectures += (sectionData['lectures'] as List).length;
      }
    } catch (e) {
      log('Error fetching total lectures: $e');
    }
    return totalLectures;
  }

  Future<void> updateUser({
    String? uid,
    String? firstName,
    String? lastName,
    String? displayName,
    String? bio,
    DateTime? dob,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set(
        {
          'firstName': firstName,
          'lastName': lastName,
          'fullName': displayName,
          'bio': bio,
          'dob': dob != null ? Timestamp.fromDate(dob) : null,
        },
        SetOptions(merge: true),
      );
    } catch (error) {
      log('Error updating user data: $error');
    }
  }

  Future<Map<String, dynamic>> getWatchedLecturesForCourse(
      String courseId) async {
    if (user == null) {
      return {};
    }

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('watchedVideos').doc(user!.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        if (data.containsKey(courseId)) {
          return data[courseId] as Map<String, dynamic>;
        }
      }
      return {};
    } catch (e) {
      log('Error fetching watched lectures for course: $e');
      return {};
    }
  }

  void checkWatchedLectures() async {
    Map<String, dynamic> watchedLectures = await getWatchedLectures();

    if (watchedLectures.isEmpty) {
      log('No lectures watched yet.');
      return;
    }

    watchedLectures.forEach((courseId, sections) {
      log('Course ID: $courseId');
      (sections as Map<String, dynamic>).forEach((sectionId, lectures) {
        log('  Section ID: $sectionId');
        (lectures as Map<String, dynamic>).forEach((lectureId, watched) {
          if (watched) {
            log('Lecture ID: $lectureId - Watched');
          } else {
            log(' Lecture ID: $lectureId - Not Watched');
          }
        });
      });
    });
  }

  Future<void> userRegistration(
      String? uid,
      String? email,
      String? photoURL,
      String firstName,
      String lastName,
      int gender,
      DateTime dob,
     ) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'firstName': firstName,
        'lastName': lastName,
        'fullName': '$firstName$lastName',
        'photoURL': photoURL,
        'email': email,
        'gender': gender,
        'dob': dob,
      
      }, SetOptions(merge: true));
    } catch (error) {
      log("Error registering user: $error");
    }
  }

  Stream<bool> isInformationComplete(User user) async* {
    final CollectionReference users = _firestore.collection('users');
    try {
      // Listen to changes in the user's document
      Stream<DocumentSnapshot> documentStream = users.doc(user.uid).snapshots();

      await for (DocumentSnapshot snapshot in documentStream) {
        // Check if the document exists and if all required fields are present
        if (snapshot.exists) {
          Map<String, dynamic> userData =
              snapshot.data() as Map<String, dynamic>;
          if (userData.containsKey('firstName') &&
              userData.containsKey('lastName')) {
            // Required fields are present
            yield true;
          } else {
            // Information is not complete
            yield false;
          }
        } else {
          // Document does not exist, information is not complete
          yield false;
        }
      }
    } catch (error) {
      log('Error checking information completeness: $error');
      yield false;
    }
  }

  Future<String?> updatePhotoUser(String imageUrl) async {
    if (user == null) {
      log('User is null. Cannot save image URL.');
      return '';
    }

    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('users').doc(user!.uid).get();

      if (docSnapshot.exists) {
        await _firestore.collection('users').doc(user!.uid).update({
          'photoURL': imageUrl,
        });
        return '';
      } else {
        log('Document does not exist. Creating new document with photoURL.');
        await _firestore.collection('users').doc(user!.uid).set({
          'photoURL': imageUrl,
        });
        return '';
      }
    } on FirebaseException catch (e) {
      showFriendlyErrorSnackbar(e);
    }
    return null;
  }
}
