import 'dart:io';
import 'dart:math';
import 'package:e_leaningapp/di/dependency_injection.dart';
import 'package:e_leaningapp/export/export.dart';
import 'package:flutter/foundation.dart';

import '../../utils/show_error_utils.dart';

class FirebaseApiQuiz{
  final FirebaseFirestore _firestore = locator<FirebaseFirestore>();

  Future<int> fetchTotalQuestions(String courseId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('quizzes')
          .doc(courseId)
          .collection('questions')
          .limit(10)
          .get();

      List<Map<String, dynamic>> fetchedQuestions =
          querySnapshot.docs.map((doc) => doc.data()).toList();

      for (var question in fetchedQuestions) {
        if (question['options'] != null && question['options'] is List) {
          List<dynamic> options = question['options'];
          options.shuffle();
        }
      }

      return fetchedQuestions.length;
    } catch (error) {
      if (kDebugMode) {
        debugPrint("Error fetching questions: $e");
      }
      if (error is SocketException) {
        showSnackbar('No internet connection. Please check your network.');
      } else if (error is TimeoutException) {
        showSnackbar('Connection timed out. Please try again.');
      } else {
        showSnackbar('Error fetching quiz count: $error');
      }
      return 0;
    }
  }
}