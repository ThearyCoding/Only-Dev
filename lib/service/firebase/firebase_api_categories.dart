import 'dart:developer';
import '../../export/curriculum_export.dart';

class FirebaseApiCategories {
  final FirebaseFirestore _firestore = locator<FirebaseFirestore>();

  Future<List<CategoryModel>> getCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection("categories").get();
      return querySnapshot.docs
          .map((doc) =>
              CategoryModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Error fetching categories: $e');
      return [];
    }
  }

  Stream<List<CategoryModel>> getCategoriesStream() {
    return _firestore.collection("categories").snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CategoryModel.fromJson(doc.data())).toList());
  }
}
