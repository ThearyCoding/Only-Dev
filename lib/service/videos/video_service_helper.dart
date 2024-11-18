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
  Set<String> downloadedVideos = {};
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

  BetterPlayerController? betterPlayerController;
  String? currentVideoUrl;

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
  
  // Check if the BetterPlayerController exists and if it's already playing the correct video
  if (betterPlayerController != null && currentVideoUrl == videoUrl) {
    // If the video URL is the same, resume playback from the start position
    await betterPlayerController!.seekTo(Duration(milliseconds: startPosition));
    betterPlayerController!.play();
    log("Resumed playback with existing BetterPlayerController");
  } else {
    // Dispose of the existing controller if it exists and video URL has changed
    if (betterPlayerController != null) {
      betterPlayerController!.dispose();
      betterPlayerController = null;
      log("Disposed of previous BetterPlayerController due to URL change");
    }

    // Initialize a new BetterPlayerController with the new video URL
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
    log("Initialized new BetterPlayerController");

    // Update the current video URL to keep track of the loaded video
    currentVideoUrl = videoUrl;
  }
}


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

    BetterPlayerController newBetterPlayerController = BetterPlayerController(
      configurationBetterPlayer(startPosition),
      betterPlayerDataSource: dataSource,
    );

    bool hasUpdatedViewCount = false;

    newBetterPlayerController.addEventsListener((event) async {
      if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
        final currentPosition = newBetterPlayerController
                .videoPlayerController?.value.position.inMilliseconds ??
            0;
        final totalDuration = newBetterPlayerController
                .videoPlayerController?.value.duration?.inMilliseconds ??
            0;
        await saveVideoProgress(
          videoUrl,
          lectureProvider.selectedIndexVideo,
          sectionId,
          lectureId,
          currentPosition,
          totalDuration,
          currentPosition == totalDuration,
          courseId,
        );
      }

      if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
        if (!hasUpdatedViewCount) {
          hasUpdatedViewCount = true;
          _handleVideoEnded(categoryId, courseId, sectionId, lectureId);
        }
      }
    });

    _betterPlayerKey = GlobalKey();
    newBetterPlayerController.setBetterPlayerGlobalKey(_betterPlayerKey);
    saveSectionExpanded(courseId, sectionId, lectureId);
    betterPlayerController = newBetterPlayerController;
    setCurrentPlayingVideo(videoUrl, videoTitle, description, timestamp, views,
        startPosition, courseId, sectionId, lectureId);
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

  Future<List<dynamic>> getSavedVideoProgress(String videoUrl) async {
    return await sharedPreferencesService.getSavedVideoProgress(videoUrl);
  }

Future<void> checkUserProgress(
    String categoryId, String courseId, List<Section> sections) async {
  // Attempt to get saved progress for the first lecture's video URL
  String videoUrl = sections[0].lectures[0].videoUrl;
  List<dynamic> progress = await sharedPreferencesService.getSavedVideoProgress(videoUrl);

  int lastWatchedIndex = 0;
  String sectionId = sections[0].id;
  String lectureId = sections[0].lectures[0].id;
  int startPosition = 0;
  int duration = sections[0].lectures[0].videoDuration;

  // If there is saved progress, update variables accordingly
  if (progress.isNotEmpty) {
    lastWatchedIndex = progress[0];
    sectionId = progress[1];
    lectureId = progress[2];
    startPosition = progress[3];
    duration = progress[4];

    // Check if last watched index is within bounds
    if (lastWatchedIndex >= sections.length) {
      lastWatchedIndex = 0;
      sectionId = sections[0].id;
      lectureId = sections[0].lectures[0].id;
      startPosition = 0;
      duration = sections[0].lectures[0].videoDuration;
    }
  }

  lectureProvider.setSelectedLectureId(lectureId);

  // Set up video player with retrieved or default values
  await setupVideoPlayer(
    videoUrl,
    sections[lastWatchedIndex].lectures[0].title,
    sections[lastWatchedIndex].lectures[0].description,
    TimeUtils.formatTimestamp(sections[lastWatchedIndex].lectures[0].timestamp),
    sections[lastWatchedIndex].lectures[0].views,
    startPosition,
    duration,
    categoryId,
    courseId,
    sectionId,
    lectureId,
  );
}

  void dispose() {
    _isDisposed = true;
    betterPlayerController?.dispose();
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
      orElse: () => Section(
        id: '',
        title: '',
        learningObjective: '',
        lectures: [],
        courseId: courseId,
      ),
    );
    Lecture? lecture;
    if (section != null) {
      lecture = section.lectures.firstWhere(
        (lecture) => lecture.id == lectureId,
        orElse: () => Lecture(
          id: '',
          title: '',
          description: description,
          videoUrl: videoUrl,
          timestamp: DateTime.now(),
          sectionId: sectionId,
          thumbnailUrl: '',
          videoDuration: 0,
          views: views,
        ),
      );
    }

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
}
