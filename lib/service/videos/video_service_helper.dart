import 'dart:developer';

import 'package:e_leaningapp/di/dependency_injection.dart';
import 'package:e_leaningapp/providers/lecture_provider.dart';
import 'package:e_leaningapp/service/shared/shared_preferences_service.dart';
import '../../export/video_service_export.dart';
import '../../utils/configuration_better_player.dart';

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
    String lectureId,
  ) async {
    if (betterPlayerController != null) {
      // Dispose of the existing controller
      betterPlayerController!.dispose();
      betterPlayerController = null;
    }

    await sharedPreferencesService.saveVideoProgress(
      videoUrl,
      lectureProvider.selectedIndexVideo,
      sectionId,
      lectureId,
      startPosition,
      duration,
      false,
      courseId,
    );

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
      lectureId,
    );
    lectureProvider.setSelectedLectureId(lectureId);
  }

  /// Initializes a new BetterPlayerController with the given configuration.
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
    String lectureId,
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

    // Add event listeners for progress and playback completion
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
            lectureProvider.selectedIndexVideo,
            sectionId,
            lectureId,
            position,
            totalDuration,
            position == totalDuration,
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

    // Save and set the current playing video details
    saveSectionExpanded(courseId, sectionId, lectureId);
    setCurrentPlayingVideo(videoUrl, videoTitle, description, timestamp, views,
        startPosition, courseId, sectionId, lectureId);
  }

  /// Handles video completion event.
  void _handleVideoEnded(
    String categoryId,
    String courseId,
    String sectionId,
    String lectureId,
  ) async {
    await UserService().updateViewCounts(
      categoryId,
      courseId,
      sectionId,
      lectureId,
    );
    log("View counts updated for video end");
  }

  Future<void> saveSectionExpanded(
      String courseId, String sectionId, String lectureId) async {
    await sharedPreferencesService.saveSectionExpanded(
        courseId, sectionId, lectureId);
  }

  Future<void> saveVideoProgress(
      String videoUrl,
      int videoIndex,
      String sectionId,
      String lectureId,
      int position,
      int duration,
      bool watched,
      String courseId) async {
    await sharedPreferencesService.saveVideoProgress(videoUrl, videoIndex,
        sectionId, lectureId, position, duration, watched, courseId);
  }

  /// Retrieves the saved video progress from SharedPreferences.
  Future<List<dynamic>> getSavedVideoProgress(String videoUrl) async {
    return await sharedPreferencesService.getSavedVideoProgress(videoUrl);
  }

  /// Checks and restores the user's progress on the current course and section.
  Future<void> checkUserProgress(
    String categoryId,
    String courseId,
    List<Section> sections,
  ) async {
    if (sections.isEmpty || sections[0].lectures.isEmpty) {
      log('No sections or lectures found.');
      return;
    }

    List<dynamic> progress =
        await getSavedVideoProgress(sections[0].lectures[0].videoUrl);
    log('Progress retrieved: $progress');

    int videoIndex = progress.isNotEmpty ? progress[0] : 0;
    int startPosition = progress.isNotEmpty ? progress[3] : 0;

    // if (videoIndex < 0 || videoIndex >= sections[0].lectures.length) {
    //   log('Invalid video index. Resetting to default.');
    //   videoIndex = 0;
    //   startPosition = 0;
    // }
    Lecture lecture = sections[0].lectures[videoIndex];
    log('Initializing video: ${lecture.title}, index: $videoIndex');

    await setupVideoPlayer(
      lecture.videoUrl,
      lecture.title,
      lecture.description,
      TimeUtils.formatTimestamp(lecture.timestamp),
      lecture.views,
      startPosition,
      lecture.videoDuration,
      categoryId,
      courseId,
      sections[0].id,
      lecture.id,
    );

    lectureProvider.setSelectedIndex(videoIndex);
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
      orElse: () => Section.emtpy(),
    );

    Lecture? lecture = section.lectures.firstWhere(
      (lecture) => lecture.id == lectureId,
      orElse: () => Lecture.empty(),
    );

    if (lecture != null) {
      videoTitle = lecture.title;
      description = lecture.description;
      timestamp = TimeUtils.formatTimestamp(lecture.timestamp);
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
}
