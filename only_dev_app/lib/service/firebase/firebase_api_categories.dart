import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../di/dependency_injection.dart';
import '../../model/category_model.dart';

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
