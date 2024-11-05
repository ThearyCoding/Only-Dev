import 'dart:developer';

import 'package:e_leaningapp/providers/lecture_provider.dart';
import '../../export/video_service_export.dart';
import '../../utils/configuration_better_player.dart';

class VideoPlayerHelper {
  final LectureProvider lectureProvider;
  final User? user;
  GlobalKey _betterPlayerKey = GlobalKey();

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
    String categoryId,
    String courseId,
    String sectionId,
    String lectureId,
  ) async {
    // Dispose of BetterPlayerController if it exists and URL has changed
    if (betterPlayerController != null) {
      if (currentVideoUrl == videoUrl) {
        await betterPlayerController!
            .seekTo(Duration(milliseconds: startPosition));
        betterPlayerController!.play();
        log("BetterPlayerController resumed with existing video");
      } else {
        betterPlayerController!.dispose();
        betterPlayerController = null;
        log("Disposed of previous BetterPlayerController due to URL change");
      }
    }

    // Initialize a new BetterPlayerController if null
    if (betterPlayerController == null) {
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

      // Update the current video URL
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
        await saveVideoProgress(
          courseId,
          lectureProvider.selectedIndexVideo,
          sectionId,
          lectureId,
          videoUrl,
          newBetterPlayerController
                  .videoPlayerController?.value.position.inMilliseconds ??
              0,
          newBetterPlayerController.videoPlayerController?.value.position ==
              newBetterPlayerController.videoPlayerController?.value.duration,
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

  Future<void> saveVideoProgress(
      String courseId,
      int videoIndex,
      String sectionId,
      String lectureId,
      String videoUrl,
      int position,
      bool watched) async {
    final prefs = await SharedPreferences.getInstance();
    String userKey = '${user!.uid}_${courseId}_progress';
    await prefs.setStringList(userKey, [
      videoIndex.toString(),
      sectionId,
      lectureId,
      videoUrl,
      position.toString(),
      watched.toString()
    ]);
  }

  Future<void> saveSectionExpanded(
      String courseId, String sectionId, lectureId) async {
    final prefs = await SharedPreferences.getInstance();
    String userKey = '${user!.uid}_${courseId}_sectionExpanded';
    await prefs.setStringList(userKey, [
      sectionId,
      lectureId,
    ]);
  }

  Future<List<dynamic>> getSavedVideoProgress(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    String userKey = '${user!.uid}_${courseId}_progress';
    List<String>? progress = prefs.getStringList(userKey);

    if (progress != null && progress.length == 6) {
      int videoIndex = int.parse(progress[0]);
      String sectionId = progress[1];
      String lectureId = progress[2];
      String videoUrl = progress[3];
      int position = int.parse(progress[4]);
      bool watched = progress[5] == 'true';
      return [videoIndex, sectionId, lectureId, videoUrl, position, watched];
    }

    return [];
  }

  Future<void> checkUserProgress(
      String categoryId, String courseId, List<Section> sections) async {
    List<dynamic> progress = await getSavedVideoProgress(courseId);
    int lastWatchedIndex = 0;
    String sectionId = sections[0].id;
    String lectureId = sections[0].lectures[0].id;
    String videoUrl = sections[0].lectures[0].videoUrl;
    int startPosition = 0;

    if (progress.isNotEmpty) {
      lastWatchedIndex = progress[0];
      sectionId = progress[1];
      lectureId = progress[2];
      videoUrl = progress[3];
      startPosition = progress[4];

      if (lastWatchedIndex >= sections.length) {
        lastWatchedIndex = 0;
        sectionId = sections[lastWatchedIndex].id;
        lectureId = sections[lastWatchedIndex].lectures[0].id;
        videoUrl = sections[lastWatchedIndex].lectures[0].videoUrl;
        startPosition = 0;
      }
    }
    lectureProvider
        .setSelectedLectureId(sections[lastWatchedIndex].lectures[0].id);
    await setupVideoPlayer(
      videoUrl,
      sections[lastWatchedIndex].lectures[0].title,
      sections[lastWatchedIndex].lectures[0].description,
      TimeUtils.formatTimestamp(
          sections[lastWatchedIndex].lectures[0].timestamp),
      sections[lastWatchedIndex].lectures[0].views,
      startPosition,
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
