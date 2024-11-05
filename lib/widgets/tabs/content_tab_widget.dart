import 'dart:io';
import 'package:e_leaningapp/providers/lecture_provider.dart';
import 'package:e_leaningapp/widgets/loadings/build_content_loading_shimmer.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:provider/provider.dart';
import '../../export/export.dart';
// ignore: depend_on_referenced_packages
import '../../utils/show_error_utils.dart';
import '../list-widget/list_item_widget.dart';

class ContentTabWidget extends StatefulWidget {
  final String categoryId;
  final String courseId;
  final Function(
    String videoUrl,
    String videoTitle,
    String description,
    String timestamp,
    num views,
    int position,
    String courseId,
    String sectionId,
    String lectureId,
  ) playVideoCallback;

  const ContentTabWidget({
    Key? key,
    required this.categoryId,
    required this.courseId,
    required this.playVideoCallback,
  }) : super(key: key);

  @override
  ContentTabWidgetState createState() => ContentTabWidgetState();
}

class ContentTabWidgetState extends State<ContentTabWidget> {
  late LectureProvider provider;
  final User? user = FirebaseAuth.instance.currentUser;
  var downloadManager = DownloadManager();
  Set<String> downloadedVideos = {};
  var savedDir = "";
  @override
  void initState() {
    super.initState();
    getApplicationSupportDirectory().then((value) => savedDir = value.path);
    provider = Provider.of<LectureProvider>(context, listen: false);
    provider.loadLastWatchedLecture(widget.courseId);
    provider.loadWatchedLectures();
    _loadDownloadedVideos();
  }

  Future<void> _loadDownloadedVideos() async {
    try {
      final Set<String> videos = {};
      if (!mounted) return;
      setState(() {
        downloadedVideos = videos;
      });
    } catch (e) {
      showSnackbar('Failed to load downloaded videos: $e');
    }
  }

  double progress = 0.0;


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final lectureProvider = Provider.of<LectureProvider>(context);

    return Scaffold(
        body: lectureProvider.isLoading
            ? const BuildContentLoadingShimmer()
            : ListView(
                key: const PageStorageKey<String>('video-tab'),
                children: provider.sections.map<Widget>((Section section) {
                  bool isSectionExpanded =
                      provider.isSectionExpanded(section.id);
                  int index = provider.sections.indexOf(section);
                  bool isLastSection = index == provider.sections.length - 1;

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
                        child: Column(
                          children: <Widget>[
                            ScrollOnExpand(
                              scrollOnExpand: true,
                              scrollOnCollapse: false,
                              child: ExpandablePanel(
                                theme: ExpandableThemeData(
                                    headerAlignment:
                                        ExpandablePanelHeaderAlignment.center,
                                    tapBodyToCollapse: false,
                                    iconColor: isDarkMode
                                        ? Colors.white
                                        : Colors.black),
                                header: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    'Section ${index + 1}: ${section.title}',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                collapsed: Text(
                                  // ignore: avoid_types_as_parameter_names
                                  '${section.lectures.length} lectures | ${TimeUtils.formatDuration(section.lectures.fold<int>(0, (sum, lecture) => sum + lecture.videoDuration))}',
                                  softWrap: true,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                expanded: Column(
                                  children: section.lectures
                                      .map<Widget>((Lecture lecture) {
                                    bool isWatched = provider.isLectureWatched(
                                        widget.courseId,
                                        section.id,
                                        lecture.id);

                                    return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 8.0),
                                        child: ListItem(
                                            provider: provider,
                                            isWatched: isWatched,
                                            onTap: () {
                                              if (provider.selectedLectureId ==
                                                  lecture.id) {
                                                return;
                                              }
                                              widget.playVideoCallback(
                                                lecture.videoUrl,
                                                lecture.title,
                                                lecture.description,
                                                TimeUtils.formatTimestamp(
                                                    lecture.timestamp),
                                                lecture.views,
                                                0,
                                                widget.courseId,
                                                section.id,
                                                lecture.id,
                                              );
                                              provider.setSelectedLectureId(
                                                  lecture.id);
                                              provider.setCurrentPlayingVideo(
                                                  lecture.title,
                                                  lecture.description,
                                                  TimeUtils.formatTimestamp(
                                                      lecture.timestamp),
                                                  lecture.views.toInt());
                                              provider.saveSectionExpanded(
                                                  widget.courseId,
                                                  section.id,
                                                  lecture.id);
                                            },
                                            onDownloadPlayPausedPressed:
                                                (url) async {
                                              setState(() {
                                                var task = downloadManager
                                                    .getDownload(url);

                                                if (task != null &&
                                                    !task.status.value
                                                        .isCompleted) {
                                                  switch (task.status.value) {
                                                    case DownloadStatus
                                                          .downloading:
                                                      downloadManager
                                                          .pauseDownload(url);
                                                      break;
                                                    case DownloadStatus.paused:
                                                      downloadManager
                                                          .resumeDownload(url);
                                                      break;
                                                    case DownloadStatus.queued:
                                                    case DownloadStatus
                                                          .completed:
                                                      showSnackbar(
                                                          'Download completed');

                                                    case DownloadStatus.failed:
                                                      showSnackbar(
                                                          'Download failed');

                                                    case DownloadStatus
                                                          .canceled:
                                                  }
                                                } else {
                                                  downloadManager.addDownload(
                                                      url,
                                                      "$savedDir/${downloadManager.getFileNameFromUrl(url)}");
                                                }
                                              });
                                            },
                                            onDelete: (url) {
                                              var fileName =
                                                  "$savedDir/${downloadManager.getFileNameFromUrl(url)}";
                                              var file = File(fileName);
                                              file.delete();

                                              downloadManager
                                                  .removeDownload(url);
                                              setState(() {});
                                            },
                                            lecture: lecture,
                                            downloadTask:
                                                downloadManager.getDownload(
                                                    lecture.videoUrl)));
                                  }).toList(),
                                ),
                                builder: (_, collapsed, expanded) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, bottom: 5),
                                    child: Expandable(
                                      collapsed: collapsed,
                                      expanded: expanded,
                                      theme: const ExpandableThemeData(
                                          crossFadePoint: 0),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ));
  }
}
