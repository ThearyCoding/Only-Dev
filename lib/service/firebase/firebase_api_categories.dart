import 'dart:developer';

import 'package:e_leaningapp/di/dependency_injection.dart';
import 'package:e_leaningapp/export/curriculum_export.dart';

class FirebaseApiCategories{
  final FirebaseFirestore _firestore = locator<FirebaseFirestore>();

  Future<List<CategoryModel>> getCategories() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("categories").get();
      return querySnapshot.docs.map((doc) {
        return CategoryModel(
          id: doc.get('id'),
          title: doc.get('title'),
          imageUrl: doc.get('imageUrl'),
        );
      }).toList();
    } catch (e) {
      log('Error fetching categories: $e');
      return [];
    }
  }

    Stream<List<CategoryModel>> getCategoriesStream() {
    return _firestore.collection("categories").snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CategoryModel.fromSnapshot(doc)).toList());
  }
}