import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import '/../di/dependency_injection.dart';

import '../../model/section_model.dart';

class FirebaseApiSection {
  final FirebaseFirestore _firestore = locator<FirebaseFirestore>();

  Future<List<Section>> fetchSections(
      String categoryId, String courseId) async {
    try {
      final querySnapshot = await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('courses')
          .doc(courseId)
          .collection('sections')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Section.fromFirestore(doc))
          .toList();
    } catch (error) {
      log('Error fetching sections: $error');
      return [];
    }
  }
}
