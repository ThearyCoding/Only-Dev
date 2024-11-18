import '../../export/export.dart';
import '../../export/topic_export.dart';

class TopicsScreen extends StatefulWidget {
  final String? title;
  final String? courseId;
  final String? categoryId;

  const TopicsScreen({super.key, this.title, this.courseId, this.categoryId});

  @override
  TopicsScreenState createState() => TopicsScreenState();
}

class TopicsScreenState extends State<TopicsScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerHelper? _videoPlayerHelper;
  late TabController _tabController;
  int selectedTileIndex = 0;
  late LectureProvider lectureProvider;

  final User? user = locator<FirebaseAuth>().currentUser;
  final PanelController _panelController = PanelController();
  final PageStorageBucket _bucket = PageStorageBucket();
  Set<String> downloadedVideos = {};
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    lectureProvider = Provider.of<LectureProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _videoPlayerHelper = VideoPlayerHelper(
        lectureProvider: lectureProvider,
        user: user,
        downloadedVideos: downloadedVideos,
      );

      if (widget.categoryId != null &&
          widget.courseId != null &&
          widget.title != null) {
        lectureProvider
            .getSections(widget.categoryId ?? '', widget.courseId ?? '')
            .then(
          (value) {
            _videoPlayerHelper?.initVideoPlayer(
              widget.categoryId ?? '',
              widget.courseId!,
              lectureProvider.sections,
              () => setState(() {}),
            );
          },
        );
      }
    });
  

    _tabController.addListener(() {
      if (_tabController.index == 1 && !lectureProvider.hasFetchedQuestions) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          lectureProvider.fetchTotalQuestions(widget.courseId ?? '');
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoPlayerHelper!.dispose();
    super.dispose();
  }

  void clearState() {
    lectureProvider.setCurrentPlayingVideo('', '', '', 0);
    lectureProvider.setSelectedLectureId('');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localization = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          widget.title ?? 'Topics',
          style: TextStyle(
              color: isDark ? Colors.white : Colors.black, fontSize: 16),
        ),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          splashRadius: 20,
          tooltip: localization.back,
          icon: Icon(
            size: 16,
            Icons.arrow_back_ios,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          onPressed: () {
            clearState();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RoutesPath.home);
            }
          },
        ),
      ),
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: 0,
        maxHeight: 600,
        panel: DraggableScrollableSheet(
          initialChildSize: 1.0,
          minChildSize: 0.4,
          maxChildSize: 1.0,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Description",
                            style: TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            onPressed: () {
                              _panelController.close();
                              lectureProvider.toggleDescriptionExpansion();
                            },
                            icon: SvgPicture.asset(
                              width: 20,
                              height: 20,
                              'assets/icons/icons8-cancel.svg',
                              // ignore: deprecated_member_use
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          )
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    lectureProvider.videoTitle,
                                    maxLines: null,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 15, bottom: 0.8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        "${lectureProvider.views.numeral(digits: 2)} Views"),
                                    const SizedBox(
                                      width: 200,
                                    ),
                                    Text(lectureProvider.timestamp),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              DescriptionWidget(
                                videoDescription:
                                    lectureProvider.videoDescription,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ));
          },
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _videoPlayerHelper?.betterPlayerController != null
                  ? BetterPlayer(
                      controller: _videoPlayerHelper!.betterPlayerController!,
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )),
            ),
            Consumer<LectureProvider>(
              builder: (context, controller, child) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.videoTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text(
                          "${controller.views} Views",
                        ),
                        const SizedBox(width: 20),
                        Text(controller.timestamp),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            controller.toggleDescriptionExpansion();
                            _panelController.open();
                            _videoPlayerHelper!.betterPlayerController!.pause();
                          },
                          child: Text(
                            controller.isDescriptionExpanded
                                ? '...less'
                                : '...more',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            TabBar(
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                return states.contains(WidgetState.focused)
                    ? null
                    : Colors.transparent;
              }),
              controller: _tabController,
              indicator: RectangularIndicator(
                  color: Colors.blueAccent.shade400.withOpacity(.3)),
              tabs: const [
                Tab(text: 'Video'),
                Tab(text: 'Practice'),
              ],
            ),
            Expanded(
              child: PageStorage(
                bucket: _bucket,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ContentTabWidget(
                      categoryId: widget.categoryId!,
                      courseId: widget.courseId!,
                      playVideoCallback: (videoUrl,
                          videoTitle,
                          description,
                          timestamp,
                          views,
                          position,
                          duration,
                          courseId,
                          sectionId,
                          lectureId) {
                        _videoPlayerHelper!.setupVideoPlayer(
                          videoUrl,
                          videoTitle,
                          description,
                          timestamp,
                          views,
                          position,
                          duration,
                          widget.categoryId ?? '',
                          courseId,
                          sectionId,
                          lectureId,
                        );
                        setState(() {});
                      },
                    ),
                    QuizTabWidget(
                      categoryId: widget.categoryId ?? '',
                      courseId: widget.courseId ?? '',
                      title: widget.title ?? '',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
