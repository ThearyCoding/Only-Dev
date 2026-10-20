import 'dart:developer';
import 'package:better_player/better_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:only_dev_app/data/repositories/course_repository.dart';
import 'package:only_dev_app/data/repositories/enrollment_repository.dart';
import 'package:only_dev_app/data/repositories/quiz_repository.dart';
import 'package:only_dev_app/model/lecture_model.dart';
import 'package:only_dev_app/model/section_model.dart';
import 'package:only_dev_app/service/shared/shared_preferences_service.dart';
import 'package:only_dev_app/utils/app_toast_utils.dart';
import 'package:only_dev_app/utils/configuration_better_player.dart';

class CourseContentParams {
  final String courseId;
  final String categoryId;

  const CourseContentParams({
    required this.courseId,
    required this.categoryId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseContentParams &&
          runtimeType == other.runtimeType &&
          courseId == other.courseId &&
          categoryId == other.categoryId;

  @override
  int get hashCode => courseId.hashCode ^ categoryId.hashCode;
}

class CourseContentState {
  final bool isLoading;
  final String? errorMessage;
  final List<Section> sections;
  final Lecture? currentLecture;
  final Section? currentSection;
  final String selectedLectureId;
  final int selectedSectionIndex;
  final int selectedLectureIndex;
  final BetterPlayerController? betterPlayerController;
  final bool isPanelOpen;
  final int activeTabIndex;
  final int totalQuestions;
  final bool loadingQuestions;
  final Set<String> downloadedVideos;

  const CourseContentState({
    this.isLoading = true,
    this.errorMessage,
    this.sections = const [],
    this.currentLecture,
    this.currentSection,
    this.selectedLectureId = '',
    this.selectedSectionIndex = 0,
    this.selectedLectureIndex = 0,
    this.betterPlayerController,
    this.isPanelOpen = false,
    this.activeTabIndex = 0,
    this.totalQuestions = 0,
    this.loadingQuestions = false,
    this.downloadedVideos = const {},
  });

  CourseContentState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Section>? sections,
    Lecture? currentLecture,
    Section? currentSection,
    String? selectedLectureId,
    int? selectedSectionIndex,
    int? selectedLectureIndex,
    BetterPlayerController? betterPlayerController,
    bool clearPlayerController = false,
    bool? isPanelOpen,
    int? activeTabIndex,
    int? totalQuestions,
    bool? loadingQuestions,
    Set<String>? downloadedVideos,
  }) {
    return CourseContentState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      sections: sections ?? this.sections,
      currentLecture: currentLecture ?? this.currentLecture,
      currentSection: currentSection ?? this.currentSection,
      selectedLectureId: selectedLectureId ?? this.selectedLectureId,
      selectedSectionIndex: selectedSectionIndex ?? this.selectedSectionIndex,
      selectedLectureIndex: selectedLectureIndex ?? this.selectedLectureIndex,
      betterPlayerController: clearPlayerController
          ? null
          : (betterPlayerController ?? this.betterPlayerController),
      isPanelOpen: isPanelOpen ?? this.isPanelOpen,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      loadingQuestions: loadingQuestions ?? this.loadingQuestions,
      downloadedVideos: downloadedVideos ?? this.downloadedVideos,
    );
  }
}

class CourseContentNotifier extends StateNotifier<CourseContentState> {
  final CourseRepository _courseRepository;
  final EnrollmentRepository _enrollmentRepository;
  final QuizRepository _quizRepository;
  final SharedPreferencesService _sharedPreferencesService;
  final String courseId;
  final String categoryId;

  CourseContentNotifier({
    required CourseRepository courseRepository,
    required EnrollmentRepository enrollmentRepository,
    required QuizRepository quizRepository,
    required SharedPreferencesService sharedPreferencesService,
    required this.courseId,
    required this.categoryId,
  })  : _courseRepository = courseRepository,
        _enrollmentRepository = enrollmentRepository,
        _quizRepository = quizRepository,
        _sharedPreferencesService = sharedPreferencesService,
        super(const CourseContentState());

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final course = await _courseRepository.getCourseById(courseId);
      final sections = course.sections ?? [];

      if (sections.isEmpty) {
        state = state.copyWith(isLoading: false, sections: []);
        return;
      }

      int sectionIdx = 0;
      int lectureIdx = 0;

      final savedProgress =
          await _sharedPreferencesService.getSectionExpanded(courseId);
      if (savedProgress != null) {
        final sIdx = savedProgress['sectionIndex'] as int?;
        final lIdx = savedProgress['lectureIndex'] as int?;
        if (sIdx != null && sIdx >= 0 && sIdx < sections.length) {
          sectionIdx = sIdx;
        }
        if (lIdx != null &&
            lIdx >= 0 &&
            lIdx < sections[sectionIdx].lectures.length) {
          lectureIdx = lIdx;
        }
      }

      var targetSection = sections[sectionIdx];
      Lecture? targetLecture;

      if (targetSection.lectures.isNotEmpty &&
          lectureIdx < targetSection.lectures.length) {
        targetLecture = targetSection.lectures[lectureIdx];
      }

      // If initial target lecture has no valid video, scan for first playable lecture
      if (targetLecture == null || targetLecture.videoUrl.trim().isEmpty) {
        for (int s = 0; s < sections.length; s++) {
          final l = sections[s]
              .lectures
              .where((lec) => lec.videoUrl.trim().isNotEmpty)
              .firstOrNull;
          if (l != null) {
            sectionIdx = s;
            targetSection = sections[s];
            lectureIdx = targetSection.lectures.indexOf(l);
            targetLecture = l;
            break;
          }
        }
      }

      state = state.copyWith(
        isLoading: false,
        sections: sections,
        currentSection: targetSection,
        selectedSectionIndex: sectionIdx,
        selectedLectureIndex: lectureIdx,
        selectedLectureId: targetLecture?.id ?? '',
        currentLecture: targetLecture,
      );

      if (targetLecture != null && targetLecture.videoUrl.trim().isNotEmpty) {
        await playLecture(targetLecture, targetSection, autoPlay: true);
      }
    } catch (e) {
      log('CourseContentNotifier initialize error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> playLecture(
    Lecture lecture,
    Section section, {
    bool autoPlay = true,
  }) async {
    if (lecture.videoUrl.trim().isEmpty) {
      AppToastUtils.warning('This lecture has no streaming video.');
      return;
    }

    try {
      state.betterPlayerController?.dispose();
    } catch (_) {}

    final sectionIdx = state.sections.indexOf(section);
    final lectureIdx = section.lectures.indexOf(lecture);

    int startPosition = 0;
    try {
      final progress = await _sharedPreferencesService
          .getSavedVideoProgress(lecture.videoUrl);
      startPosition = (progress?['position'] as int?) ?? 0;
      if (startPosition < 0 ||
          (lecture.videoDuration > 0 && startPosition > lecture.videoDuration)) {
        startPosition = 0;
      }
    } catch (_) {}

    final playerConfig = configurationBetterPlayer(
      startPosition * 1000,
    );

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      lecture.videoUrl.trim(),
      cacheConfiguration: cacheConfiguration(lecture.videoUrl.trim()),
    );

    final controller = BetterPlayerController(
      playerConfig,
      betterPlayerDataSource: dataSource,
    );

    controller.addEventsListener((BetterPlayerEvent event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
        final positionSec =
            controller.videoPlayerController?.value.position.inSeconds ?? 0;
        final durationSec =
            controller.videoPlayerController?.value.duration?.inSeconds ?? 0;

        if (positionSec > 0) {
          _sharedPreferencesService.saveVideoProgress(
            lecture.videoUrl,
            section.id,
            sectionIdx >= 0 ? sectionIdx : 0,
            lecture.id,
            lectureIdx >= 0 ? lectureIdx : 0,
            positionSec,
            durationSec,
            courseId,
          );

          _enrollmentRepository
              .updateProgress(
                courseId,
                lecture.id,
                positionSeconds: positionSec,
                markCompleted:
                    durationSec > 0 && positionSec >= (durationSec * 0.9),
              )
              .catchError((_) {});
        }
      } else if (event.betterPlayerEventType ==
          BetterPlayerEventType.finished) {
        _enrollmentRepository
            .updateProgress(
              courseId,
              lecture.id,
              markCompleted: true,
            )
            .catchError((_) {});
        _playNextLecture();
      }
    });

    await _sharedPreferencesService.saveSectionExpanded(
      courseId,
      section.id,
      sectionIdx >= 0 ? sectionIdx : 0,
      lecture.id,
      lectureIdx >= 0 ? lectureIdx : 0,
    );

    state = state.copyWith(
      currentLecture: lecture,
      currentSection: section,
      selectedLectureId: lecture.id,
      selectedSectionIndex: sectionIdx >= 0 ? sectionIdx : 0,
      selectedLectureIndex: lectureIdx >= 0 ? lectureIdx : 0,
      betterPlayerController: controller,
    );
  }

  void _playNextLecture() {
    final curSecIdx = state.selectedSectionIndex;
    final curLecIdx = state.selectedLectureIndex;
    final sections = state.sections;

    if (curSecIdx < sections.length) {
      final currentSection = sections[curSecIdx];
      if (curLecIdx + 1 < currentSection.lectures.length) {
        final nextLecture = currentSection.lectures[curLecIdx + 1];
        playLecture(nextLecture, currentSection);
        return;
      }

      if (curSecIdx + 1 < sections.length) {
        final nextSection = sections[curSecIdx + 1];
        if (nextSection.lectures.isNotEmpty) {
          final nextLecture = nextSection.lectures.first;
          playLecture(nextLecture, nextSection);
        }
      }
    }
  }

  Future<void> fetchTotalQuestions() async {
    if (state.totalQuestions > 0 || state.loadingQuestions) return;
    state = state.copyWith(loadingQuestions: true);
    try {
      final count = await _quizRepository.fetchTotalQuestions(courseId);
      state = state.copyWith(totalQuestions: count, loadingQuestions: false);
    } catch (_) {
      state = state.copyWith(loadingQuestions: false);
    }
  }

  void setPanelOpen(bool open) {
    state = state.copyWith(isPanelOpen: open);
    if (open) {
      state.betterPlayerController?.pause();
    } else {
      state.betterPlayerController?.play();
    }
  }

  void setActiveTab(int index) {
    state = state.copyWith(activeTabIndex: index);
    if (index == 1) {
      fetchTotalQuestions();
    }
  }

  @override
  void dispose() {
    try {
      state.betterPlayerController?.dispose();
    } catch (_) {}
    super.dispose();
  }
}
