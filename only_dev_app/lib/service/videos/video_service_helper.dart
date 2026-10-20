import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../di/dependency_injection.dart';
import '../../model/lecture_model.dart';
import '../../model/section_model.dart';
import 'package:only_dev_app/features/courses/provider/lecture_provider.dart';
import '../../utils/configuration_better_player.dart';
import '../../utils/time_utils.dart';
import '../../data/repositories/enrollment_repository.dart';
import '../shared/shared_preferences_service.dart';

class VideoPlayerHelper {
  final LectureProvider lectureProvider;
  final User? user;
  GlobalKey _betterPlayerKey = GlobalKey();
  final SharedPreferencesService sharedPreferencesService =
      locator<SharedPreferencesService>();

  bool _isDisposed = false;
  Set<String> downloadedVideos;

  BetterPlayerController? betterPlayerController;

  VideoPlayerHelper({
    required this.lectureProvider,
    required this.user,
    required this.downloadedVideos,
  });

  /// Initialize the video player
  Future<void> initVideoPlayer(String categoryId, String courseId,
      List<Section> sections, VoidCallback onCompleted) async {
    if (sections.isNotEmpty && !_isDisposed) {
      await checkUserProgress(categoryId, courseId, sections);
    }
    if (!_isDisposed) {
      lectureProvider.setLoading(false);
      onCompleted();
    }
  }

  /// Setup video player for a specific lecture
  Future<void> setupVideoPlayer(
    String videoUrl,
    String videoTitle,
    String description,
    String timestamp,
    num views,
    int startPosition,
    int duration,
    String categoryId,
    String courseId,
    String sectionId,
    int sectionIndex,
    String lectureId,
    int lectureIndex,
  ) async {
    if (betterPlayerController != null) {
      betterPlayerController!.dispose();
    }

    // Save progress first
    await sharedPreferencesService.saveVideoProgress(
      videoUrl,
      sectionId,
      sectionIndex,
      lectureId,
      lectureIndex,
      startPosition,
      duration,
      courseId,
    );

    // Initialize BetterPlayer
    await initBetterPlayerController(
      videoUrl,
      videoTitle,
      description,
      timestamp,
      views,
      startPosition,
      categoryId,
      courseId,
      sectionId,
      sectionIndex,
      lectureId,
      lectureIndex,
    );

    // Set selected lecture ID
    lectureProvider.setSelectedLectureId(lectureId);

    // Ensure that the video is set correctly on the first setup
    setCurrentPlayingVideo(
      videoUrl,
      videoTitle,
      description,
      timestamp,
      views,
      startPosition,
      courseId,
      sectionId,
      lectureId,
    );
  }

  /// Initialize BetterPlayerController
  Future<void> initBetterPlayerController(
    String videoUrl,
    String videoTitle,
    String description,
    String timestamp,
    num views,
    int startPosition,
    String categoryId,
    String courseId,
    String sectionId,
    int sectionIndex,
    String lectureId,
    int lectureIndex,
  ) async {
    BetterPlayerDataSource dataSource =
        BetterPlayerDataSource(BetterPlayerDataSourceType.network, videoUrl,
            cacheConfiguration: cacheConfiguration(videoUrl),
            notificationConfiguration: BetterPlayerNotificationConfiguration(
              showNotification: true,
              title: videoTitle,
            ));

    BetterPlayerController newController = BetterPlayerController(
      configurationBetterPlayer(startPosition),
      betterPlayerDataSource: dataSource,
    );

    bool hasUpdatedViewCount = false;
    newController.addEventsListener((event) async {
      final position =
          newController.videoPlayerController?.value.position.inMilliseconds ??
              0;
      final totalDuration =
          newController.videoPlayerController?.value.duration?.inMilliseconds ??
              0;

      switch (event.betterPlayerEventType) {
        case BetterPlayerEventType.progress:
        case BetterPlayerEventType.initialized:
        case BetterPlayerEventType.seekTo:
          await saveVideoProgress(
            videoUrl,
            sectionId,
            sectionIndex,
            lectureId,
            lectureIndex,
            position,
            totalDuration,
            courseId,
          );
          break;

        case BetterPlayerEventType.finished:
          if (!hasUpdatedViewCount) {
            hasUpdatedViewCount = true;
            _handleVideoEnded(categoryId, courseId, sectionId, lectureId);
          }
          break;

        default:
          break;
      }
    });

    _betterPlayerKey = GlobalKey();
    newController.setBetterPlayerGlobalKey(_betterPlayerKey);
    betterPlayerController = newController;
  }

  /// Save expanded section and lecture
  Future<void> saveSectionExpanded(
    String courseId,
    String sectionId,
    int sectionIndex,
    String lectureId,
    int lectureIndex,
  ) async {
    await sharedPreferencesService.saveSectionExpanded(
        courseId, sectionId, sectionIndex, lectureId, lectureIndex);
  }

  /// Save video progress
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
    await sharedPreferencesService.saveVideoProgress(
      videoUrl,
      sectionId,
      sectionIndex,
      lectureId,
      lectureIndex,
      position,
      duration,
      courseId,
    );
  }

  Future<void> checkUserProgress(
    String categoryId,
    String courseId,
    List<Section> sections,
  ) async {
    if (sections.isEmpty || sections[0].lectures.isEmpty) {
      log('No sections or lectures found.');
      return;
    }

    // Retrieve the last watched video URL for the user
    String? lastWatchedVideoUrl =
        await sharedPreferencesService.getCurrentVideoUrl();

    String videoUrl = sections[0].lectures[0].videoUrl;

    if (lastWatchedVideoUrl != null && lastWatchedVideoUrl.isNotEmpty) {
      // If a previous video was watched, we try to use its progress
      log('User last watched: $lastWatchedVideoUrl');
      videoUrl = lastWatchedVideoUrl;
    } else {
      // Save the current video URL as the one being played if no previous URL exists
      await sharedPreferencesService.saveCurrentVideoUrl(videoUrl);
    }

    // Retrieve progress for the video (either last watched or the current one)
    Map<String, dynamic>? progress =
        await sharedPreferencesService.getSavedVideoProgress(videoUrl);
    log('Progress retrieved: $progress');

    String sectionId =
        progress?['sectionId']?.toString() ?? sections[0].id.toString();
    int sectionIndex =
        int.tryParse(progress?['sectionIndex']?.toString() ?? '0') ?? 0;
    String lectureId = progress?['lectureId']?.toString() ??
        sections[0].lectures[0].id.toString();
    int lectureIndex =
        int.tryParse(progress?['lectureIndex']?.toString() ?? '0') ?? 0;
    int startPosition =
        int.tryParse(progress?['position']?.toString() ?? '0') ?? 0;

    if (sectionIndex >= sections.length) {
      log('Section index out of bounds, using default.');
      sectionIndex = 0;
    }

    Section currentSection = sections[sectionIndex];

    if (lectureIndex >= currentSection.lectures.length) {
      log('Lecture index out of bounds, using default.');
      lectureIndex = 0;
    }

    Lecture lecture = currentSection.lectures[lectureIndex];

    await setupVideoPlayer(
      lecture.videoUrl,
      lecture.title,
      lecture.description,
      TimeUtils.formatTimestamp(lecture.createdAt),
      lecture.views,
      startPosition,
      lecture.videoDuration,
      categoryId,
      courseId,
      sectionId,
      sectionIndex,
      lectureId,
      lectureIndex,
    );
    await sharedPreferencesService.saveCurrentVideoUrl(lecture.videoUrl);

    lectureProvider.setSelectedIndex(lectureIndex);
  }

  void setCurrentPlayingVideo(
    String videoUrl,
    String videoTitle,
    String description,
    String timestamp,
    num views,
    int startPosition,
    String courseId,
    String sectionId,
    String lectureId,
  ) {
    Section? section = lectureProvider.sections.firstWhere(
      (section) => section.id == sectionId,
      orElse: () => Section.empty(),
    );

    Lecture? lecture = section.lectures.firstWhere(
      (lecture) => lecture.id == lectureId,
      orElse: () => Lecture.empty(),
    );

    if (lecture != null) {
      videoTitle = lecture.title;
      description = lecture.description;
      timestamp = TimeUtils.formatTimestamp(lecture.createdAt);
      views = lecture.views;
    }

    lectureProvider.setCurrentPlayingVideo(
        videoTitle, description, timestamp, views.toInt());
    lectureProvider.setSelectedLectureId(lectureId);
  }

  void dispose() {
    _isDisposed = true;
    betterPlayerController?.dispose();
  }

  /// Handle video end event
  void _handleVideoEnded(
    String categoryId,
    String courseId,
    String sectionId,
    String lectureId,
  ) async {
    try {
      await locator<EnrollmentRepository>().updateProgress(
        courseId,
        lectureId,
        markCompleted: true,
      );
    } catch (e) {
      log('Error updating lesson progress: $e');
    }
  }
}
