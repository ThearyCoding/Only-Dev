import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../di/dependency_injection.dart';

class SharedPreferencesService {
  String get userId => locator<FirebaseAuth>().currentUser?.uid ?? 'guest';

  SharedPreferencesService();

  /// Save expanded section and lecture with specific indices
  Future<void> saveSectionExpanded(
    String courseId,
    String sectionId,
    int sectionIndex,
    String lectureId,
    int lectureIndex,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String userKey = '${userId}_${courseId}_sectionExpanded';

    log('Saving expanded section: sectionId=$sectionId, lectureId=$lectureId, sectionIndex=$sectionIndex, lectureIndex=$lectureIndex');

    await prefs.setStringList(userKey, [
      sectionId,
      sectionIndex.toString(),
      lectureId,
      lectureIndex.toString(),
    ]);
  }

  /// Retrieve expanded section and lecture indices
  Future<Map<String, dynamic>?> getSectionExpanded(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    String userKey = '${userId}_${courseId}_sectionExpanded';

    List<String>? expandedData = prefs.getStringList(userKey);
    if (expandedData != null && expandedData.length == 4) {
      try {
        String sectionId = expandedData[0];
        int sectionIndex = int.parse(expandedData[1]);
        String lectureId = expandedData[2];
        int lectureIndex = int.parse(expandedData[3]);

    //    log('Retrieved expanded section:  sectionIndex=$sectionIndex, lectureId=$lectureId, lectureIndex=$lectureIndex');
        return {
          'sectionId': sectionId,
          'sectionIndex': sectionIndex,
          'lectureId': lectureId,
          'lectureIndex': lectureIndex,
        };
      } catch (e) {
        log('Error parsing expanded section data for courseId=$courseId: $e');
      }
    }

    log('No expanded section found for courseId=$courseId');
    return null;
  }

  /// Save video progress for a specific section and lecture
  Future<void> saveVideoProgress(
    String videoUrl,
    String sectionId,
    int sectionIndex,
    String lectureId,
    int lectureIndex,
    int position,
    int duration,
    String courseId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String userKey = '${userId}_${videoUrl}_progress';

    try {
      await prefs.setStringList(userKey, [
        sectionId,
        sectionIndex.toString(),
        lectureId,
        lectureIndex.toString(),
        position.toString(),
        duration.toString(),
        courseId,
      ]);

      //    log('Saved video progress: sectionId=$sectionId, sectionIndex=$sectionIndex, lectureId=$lectureId, lectureIndex=$lectureIndex, position=$position, duration=$duration');
    } catch (e) {
      log('Error saving video progress: $e');
    }
  }

  /// Retrieve saved video progress for a specific section and lecture
  Future<Map<String, dynamic>?> getSavedVideoProgress(String videoUrl) async {
    final prefs = await SharedPreferences.getInstance();
    String userKey =
        '${userId}_${videoUrl}_progress'; // Ensure you're using the right key

    List<String>? progress = prefs.getStringList(userKey);
    if (progress != null && progress.length == 7) {
      try {
        String sectionId = progress[0];
        int sectionIndex = int.parse(progress[1]);
        String lectureId = progress[2];
        int lectureIndex = int.parse(progress[3]);
        int position = int.parse(progress[4]);
        int duration = int.parse(progress[5]);
        String courseId = progress[6];

        //  log('Retrieved video progress: sectionId=$sectionId, sectionIndex=$sectionIndex, lectureId=$lectureId, lectureIndex=$lectureIndex, position=$position, duration=$duration');

        return {
          'sectionId': sectionId,
          'sectionIndex': sectionIndex,
          'lectureId': lectureId,
          'lectureIndex': lectureIndex,
          'position': position,
          'duration': duration,
          'courseId': courseId,
        };
      } catch (e) {
        log('Error parsing saved video progress for videoUrl=$videoUrl: $e');
      }
    }

    log('No saved video progress for videoUrl=$videoUrl');
    return null;
  }

  Future<void> saveCurrentVideoUrl(
    String videoUrl,
  ) async {
    final String key = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, videoUrl);
  }

  Future<String?> getCurrentVideoUrl() async {
    final String key = userId;
    final prefs = await SharedPreferences.getInstance();
    String? videoUrl = prefs.getString(key);
    return videoUrl;
  }
}
