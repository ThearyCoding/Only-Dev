import 'dart:developer';

import 'package:e_leaningapp/di/dependency_injection.dart';
import 'package:e_leaningapp/export/curriculum_export.dart';

class FirebaseApiLecture{

  final FirebaseFirestore _firestore = locator<FirebaseFirestore>();


 Future<String?> fetchFirstVideoUrl(
    String categoryId, String courseId) async {
  final courseRef = _firestore
      .collection('categories')
      .doc(categoryId)
      .collection('courses')
      .doc(courseId);

  try {
    // Fetch the list of sections for the course
    final sectionsSnapshot = await courseRef.collection('sections').get();
    if (sectionsSnapshot.docs.isEmpty) {
      return null; // No sections found
    }

    // Get the first section document
    final firstSectionRef = sectionsSnapshot.docs.first.reference;
    final sectionSnapshot = await firstSectionRef.get();
    final sectionData = sectionSnapshot.data() as Map<String, dynamic>;

    // Get the list of lectures from the section document
    final sectionLectures = List<Map<String, dynamic>>.from(sectionData['lectures'] ?? []);

    // Find the first lecture that contains a videoUrl
    final firstLectureWithVideoUrl = sectionLectures.firstWhere(
      (lecture) => lecture.containsKey('videoUrl') && lecture['videoUrl'] != null && lecture['videoUrl'].isNotEmpty,
      orElse: () => {},
    );

    // Return the videoUrl if found, otherwise return null
    return firstLectureWithVideoUrl.isNotEmpty ? firstLectureWithVideoUrl['videoUrl'] : null;
  } catch (e) {
    log('Error fetching first video URL: $e');
    return null;
  }
}


}