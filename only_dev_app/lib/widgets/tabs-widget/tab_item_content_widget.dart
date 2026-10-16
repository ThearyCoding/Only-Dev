import 'dart:developer';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../di/dependency_injection.dart';
import '../../model/lecture_model.dart';
import '../../model/section_model.dart';
import 'package:only_dev_app/features/courses/provider/lecture_provider.dart';
import '../../service/download/download_manager.dart';
import '../../service/shared/shared_preferences_service.dart';
import '../../utils/app_toast_utils.dart';
import '../../utils/time_utils.dart';
import '../loadings-widget/build_content_loading_shimmer.dart';
import '../list-widget/list_item_widget.dart';

class TabItemContentWidget extends StatefulWidget {
  final String categoryId;
  final String courseId;
  final Function(
    String videoUrl,
    String videoTitle,
    String description,
    String timestamp,
    num views,
    int startPosition,
    int duration,
    String courseId,
    String sectionId,
    int sectionIndex,
    String lectureId,
    int lectureIndex,
  ) playVideoCallback;

  const TabItemContentWidget({
    Key? key,
    required this.categoryId,
    required this.courseId,
    required this.playVideoCallback,
  }) : super(key: key);

  @override
  TabItemContentWidgetState createState() => TabItemContentWidgetState();
}

class TabItemContentWidgetState extends State<TabItemContentWidget> {
  late LectureProvider provider;
  User? user = locator<FirebaseAuth>().currentUser;
  var downloadManager = DownloadManager();
  final AutoScrollController autoScrollController = AutoScrollController();
  var savedDir = "";
  SharedPreferencesService? sharedPreferencesService;
  final scrollDuration = const Duration(seconds: 2);
  Set<String> downloadedVideos = {};

  @override
  void initState() {
    super.initState();
    provider = Provider.of<LectureProvider>(context, listen: false);
    getApplicationSupportDirectory().then((value) => savedDir = value.path);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAutoScroll();
    });
  }

  void _initializeAutoScroll() {
    sharedPreferencesService = SharedPreferencesService();

    provider.loadLastWatchedLecture(widget.courseId).then((_) {
      provider.loadWatchedLectures();
      _loadDownloadedVideos();
    });
  }

  void requestAutoScroll(int sectionIndex, int lectureIndex) {
    int listIndex = _calculateListIndex(sectionIndex, lectureIndex);
    _scrollToSection(listIndex);
  }

  int _calculateListIndex(int sectionIndex, int lectureIndex) {
    int index = 0;
    for (int i = 0; i < sectionIndex; i++) {
      index +=
          provider.sections[i].lectures.length + 1; // +1 for the section header
    }
    return index +
        1 +
        lectureIndex; // +1 to account for the current section header
  }

  void _scrollToSection(int index) {
    if (autoScrollController.hasClients) {
      autoScrollController.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.middle,
        duration: scrollDuration,
      );
    }
  }

  String _generateKey(int sectionIndex, int lectureIndex) {
    return '$sectionIndex-$lectureIndex';
  }

  @override
  Widget build(BuildContext context) {
    final lectureProvider = Provider.of<LectureProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return lectureProvider.isLoading
        ? const BuildContentLoadingShimmer()
        : Stack(
            children: [
              ListView.builder(
                controller: autoScrollController,
                itemCount: provider.sections.length,
                itemBuilder: (context, sectionIndex) {
                  Section section = provider.sections[sectionIndex];
                  bool isSectionExpanded =
                      provider.isSectionExpanded(sectionIndex);
                  bool isLastSection =
                      sectionIndex == provider.sections.length - 1;

                  return ExpandableNotifier(
                    initialExpanded: isSectionExpanded,
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: isLastSection ? 100 : 5,
                          top: 5,
                          left: 5,
                          right: 5),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 2,
                        child: ExpandablePanel(
                          header: _buildHeader(sectionIndex, section.title),
                          collapsed: _buildCollapsed(section.lectures),
                          expanded: Column(
                            children: List.generate(
                              section.lectures.length,
                              (lectureIndex) {
                                final key =
                                    _generateKey(sectionIndex, lectureIndex);

                                Lecture lecture =
                                    section.lectures[lectureIndex];
                                bool isWatched = provider.isLectureWatched(
                                    widget.courseId,
                                    sectionIndex,
                                    lectureIndex);

                                return AutoScrollTag(
                                  key: ValueKey(key),
                                  controller: autoScrollController,
                                  index: _calculateListIndex(
                                      sectionIndex, lectureIndex),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 8.0),
                                    child: ListItem(
                                      provider: provider,
                                      isWatched: isWatched,
                                      onTap: () =>
                                          _handlePlayVideo(lecture, section),
                                      onDownloadPlayPausedPressed: (url) =>
                                          _handleDownloadPlayPause(
                                              url, lecture.title),
                                      onDelete: (url) => _handleDelete(url),
                                      lecture: lecture,
                                      downloadTask: downloadManager
                                          .getDownload(lecture.videoUrl),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                right: 20,
                bottom: 100,
                child: FloatingActionButton(
                  elevation: 0,
                  backgroundColor: Colors.grey.shade400.withOpacity(.2),
                  onPressed: () async {
                    final expandedProgress = await sharedPreferencesService!
                        .getSectionExpanded(widget.courseId);

                    if (expandedProgress == null || expandedProgress.isEmpty) {
                      return;
                    }

                    int? sectionIndex = expandedProgress['sectionIndex'];
                    int? lectureIndex = expandedProgress['lectureIndex'];

                    if (sectionIndex == null || lectureIndex == null) {
                      return;
                    }

                    log("lectureIndex: $lectureIndex");
                    log("sectionIndex: $sectionIndex");
                    requestAutoScroll(sectionIndex, lectureIndex);
                  },
                  child: Icon(
                    Icons.arrow_downward,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          );
  }

  Widget builder(Widget collapsed, Widget expanded) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
      child: Expandable(
        collapsed: collapsed,
        expanded: expanded,
        theme: const ExpandableThemeData(crossFadePoint: 0),
      ),
    );
  }

  Future<void> _saveCompletedDownload(String url, String videoTitle) async {
    var task = downloadManager.getDownload(url);

    if (task != null && task.status.value == DownloadStatus.completed) {
      try {
        String completedFilePath = "$savedDir/$videoTitle";

        File downloadedFile =
            File(completedFilePath + DownloadManager.partialExtension);

        if (await downloadedFile.exists()) {
          await downloadedFile.rename(completedFilePath);
          log("Download completed and file saved at: $completedFilePath");
        } else {
          log("No partial file found for URL: $url");
        }
      } catch (e) {
        log("Error saving completed download: $e");
      }
    }
  }

  Future<void> _loadDownloadedVideos() async {
    try {
      final Set<String> videos = {};
      if (!mounted) return;
      setState(() {
        downloadedVideos = videos;
      });
    } catch (e) {
      AppToastUtils.error('Failed to load downloaded videos: $e');
    }
  }

  Future<void> _handlePlayVideo(Lecture lecture, Section section) async {
    try {
      if (provider.selectedLectureId == lecture.id) {
        return;
      }
      // Retrieve saved progress for the lecture
      final progress = await sharedPreferencesService!
          .getSavedVideoProgress(lecture.videoUrl);

      await sharedPreferencesService!.saveCurrentVideoUrl(lecture.videoUrl);

      // Extract the starting position and duration
      int startPosition = progress?['position'] ?? 0;
      int duration = progress?['duration'] ?? lecture.videoDuration;

      // Ensure startPosition is within valid bounds
      if (startPosition > duration || startPosition < 0) {
        startPosition = 0;
      }

      // Get section and lecture indices
      int sectionIndex = provider.sections.indexOf(section);
      if (sectionIndex == -1) {
        throw Exception("Section not found.");
      }

      int lectureIndex = section.lectures.indexOf(lecture);
      if (lectureIndex == -1) {
        throw Exception("Lecture not found in the section.");
      }

      // Update provider with the selected lecture and section details
      provider.setSelectedIndex(lectureIndex);
      provider.setSelectedLectureId(lecture.id);

      // Save the current expanded section and lecture
      await provider.saveSectionExpanded(
        widget.courseId,
        sectionIndex,
        lectureIndex,
      );

      // Trigger video playback callback
      widget.playVideoCallback(
        lecture.videoUrl,
        lecture.title,
        lecture.description,
        TimeUtils.formatTimestamp(lecture.timestamp),
        lecture.views,
        startPosition,
        duration,
        widget.courseId,
        section.id,
        sectionIndex,
        lecture.id,
        lectureIndex,
      );
    } catch (e) {
      AppToastUtils.error('Error playing video: ${e.toString()}');
    }
  }

  _handleDownloadPlayPause(String url, String title) async {
    setState(() {
      var task = downloadManager.getDownload(url);

      if (task != null && !task.status.value.isCompleted) {
        switch (task.status.value) {
          case DownloadStatus.downloading:
            downloadManager.pauseDownload(url);
            break;
          case DownloadStatus.paused:
            downloadManager.resumeDownload(url);
            break;
          case DownloadStatus.queued:
          case DownloadStatus.completed:
            downloadManager.whenDownloadComplete(url);

            if (task.status.value == DownloadStatus.completed) {
              _saveCompletedDownload(url, title);
            }
            break;

          case DownloadStatus.failed:
          case DownloadStatus.canceled:
            break;
        }
      } else {
        downloadManager.addDownload(
            url, "$savedDir/${downloadManager.getFileNameFromUrl(url)}");
      }
    });
  }

  _handleDelete(String url) {
    var fileName = "$savedDir/${downloadManager.getFileNameFromUrl(url)}";
    var file = File(fileName);
    file.delete();

    downloadManager.removeDownload(url);
    setState(() {});
  }

  Widget _buildHeader(int sectionIndex, String sectiontitle) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        'Section ${sectionIndex + 1}: $sectiontitle',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _buildCollapsed(List<Lecture> lectures) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        // ignore: avoid_types_as_parameter_names
        '${lectures.length} lectures | ${TimeUtils.formatDuration(lectures.fold<int>(0, (sum, lecture) => sum + lecture.videoDuration))} minutes',
        softWrap: true,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
