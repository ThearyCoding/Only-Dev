import 'dart:developer';

import '../../export/export.dart';
import '../../export/topic_export.dart';
import '../../service/shared/shared_preferences_service.dart';
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
    int duration,
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
  final User? user = locator<FirebaseAuth>().currentUser;
  var downloadManager = DownloadManager();
  Set<String> downloadedVideos = {};
  var savedDir = "";
  SharedPreferencesService sharedPreferencesService =
      SharedPreferencesService();

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

  Future<void> _handlePlayVideo(Lecture lecture, Section section) async {
    List<dynamic> progress =
        await sharedPreferencesService.getSavedVideoProgress(lecture.videoUrl);
    int startPosition = 0;
    int duration = 0;

    if (progress.isNotEmpty) {
      startPosition = progress[3];
      duration = progress[4];
    }

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
      lecture.id,
    );

    provider.setSelectedLectureId(lecture.id);
    provider.setCurrentPlayingVideo(lecture.title, lecture.description,
        TimeUtils.formatTimestamp(lecture.timestamp), lecture.views.toInt());
    provider.saveSectionExpanded(widget.courseId, section.id, lecture.id);
  }

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
                bool isSectionExpanded = provider.isSectionExpanded(section.id);
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
                                  tapHeaderToExpand: false,
                                  inkWellBorderRadius:
                                      BorderRadius.circular(10),
                                  iconColor:
                                      isDarkMode ? Colors.white : Colors.black),
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
                                      widget.courseId, section.id, lecture.id);

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
                                        _handlePlayVideo(lecture, section);
                                      },
                                      onDownloadPlayPausedPressed: (url) async {
                                        setState(() {
                                          var task =
                                              downloadManager.getDownload(url);

                                          if (task != null &&
                                              !task.status.value.isCompleted) {
                                            switch (task.status.value) {
                                              case DownloadStatus.downloading:
                                                downloadManager
                                                    .pauseDownload(url);
                                                break;
                                              case DownloadStatus.paused:
                                                downloadManager
                                                    .resumeDownload(url);
                                                break;
                                              case DownloadStatus.queued:
                                              case DownloadStatus.completed:
                                                downloadManager
                                                    .whenDownloadComplete(url);

                                                if (task.status.value ==
                                                    DownloadStatus.completed) {
                                                  _saveCompletedDownload(
                                                      url, lecture.title);
                                                }
                                                break;

                                              case DownloadStatus.failed:
                                              case DownloadStatus.canceled:
                                            }
                                          } else {
                                            downloadManager.addDownload(url,
                                                "$savedDir/${downloadManager.getFileNameFromUrl(url)}");
                                          }
                                        });
                                      },
                                      onDelete: (url) {
                                        var fileName =
                                            "$savedDir/${downloadManager.getFileNameFromUrl(url)}";
                                        var file = File(fileName);
                                        file.delete();

                                        downloadManager.removeDownload(url);
                                        setState(() {});
                                      },
                                      lecture: lecture,
                                      downloadTask: downloadManager
                                          .getDownload(lecture.videoUrl),
                                    ),
                                  );
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
}
