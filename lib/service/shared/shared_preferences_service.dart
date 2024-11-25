import 'dart:developer';

import 'package:e_leaningapp/di/dependency_injection.dart';
import 'package:e_leaningapp/export/app_routes_export.dart';

class SharedPreferencesService {
  final String userId = locator<FirebaseAuth>().currentUser!.uid;

  SharedPreferencesService();

  Future<void> saveSectionExpanded(
      String courseId, String sectionId, String lectureId) async {
    final prefs = await SharedPreferences.getInstance();
    String userKey = '${userId}_${courseId}_sectionExpanded';
    await prefs.setStringList(userKey, [
      sectionId,
      lectureId,
    ]);
  }

  Future<void> saveVideoProgress(
    String videoUrl,
    int videoIndex,
    String sectionId,
    String lectureId,
    int position,
    int duration,
    bool watched,
    String courseId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String userKey = '${userId}_${videoUrl}_progress';
    await prefs.setStringList(userKey, [
      videoIndex.toString(),
      sectionId,
      lectureId,
      position.toString(),
      duration.toString(),
      watched.toString(),
      courseId,
    ]);
    log('Saved progress: videoIndex: $videoIndex, position: $position');
  }

  Future<List<dynamic>> getSavedVideoProgress(String videoUrl) async {
    final prefs = await SharedPreferences.getInstance();
    String userKey = '${userId}_${videoUrl}_progress';
    List<String>? progress = prefs.getStringList(userKey);

    if (progress != null && progress.length == 7) {
      int videoIndex = int.parse(progress[0]);
      String sectionId = progress[1];
      String lectureId = progress[2];
      int position = int.parse(progress[3]);
      int duration = int.parse(progress[4]);
      bool watched = progress[5] == 'true';
      String courseId = progress[6];
      log('Retrieved progress: videoIndex: $videoIndex, position: $position');
      return [
        videoIndex,
        sectionId,
        lectureId,
        position,
        duration,
        watched,
        courseId
      ];
    }
    log('No saved progress for video');
    return [];
  }

  Future<List<String>?> getSectionExpanded(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    String userKey =
        '${FirebaseAuth.instance.currentUser!.uid}_${courseId}_sectionExpanded';
    return prefs.getStringList(userKey);
  }
}
