import '../../export/detail_export.dart';
import '../../widgets/course-widget/build_course_curriculum.dart';

class DetailCourseScreen extends StatefulWidget {
  final String categoryId;
  final String courseId;
  const DetailCourseScreen({
    super.key,
    required this.categoryId,
    required this.courseId,
  });

  @override
  State<DetailCourseScreen> createState() => _DetailCourseScreenState();
}

class _DetailCourseScreenState extends State<DetailCourseScreen> {
  final FirebaseApiQuiz _apiQuiz = locator<FirebaseApiQuiz>();
  final User? user = locator<FirebaseAuth>().currentUser;
  late RegistrationProvider registrationProvider;
  late LectureProvider lectureProvider;
  late CourseProvider courseProvider;
  double profileheight = 40;
  double converheight = 220;
  int totalVideos = 0;
  int watchedtotal = 0;
  int totalQuestionQuiz = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isBottomSheetVisible = true;
  BetterPlayerController? betterPlayerController;
  Color dominantColor = Colors.grey;
  bool isLoading = true;

  void _initializeVideoController(String? videoUrl) async {
    if (videoUrl != null && !_isYouTubeUrl(videoUrl)) {
      betterPlayerController = BetterPlayerController(
        configurationBetterPlayer(0),
        betterPlayerDataSource: BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          videoUrl,
          cacheConfiguration: cacheConfiguration(videoUrl),
        ),
      );
    }
  }

  bool _isYouTubeUrl(String? url) {
    return url != null &&
        (url.contains('youtube.com') || url.contains('youtu.be'));
  }

  @override
  void initState() {
    super.initState();
    lectureProvider = Provider.of<LectureProvider>(context, listen: false);
    _scrollController.addListener(_scrollListener);
    courseProvider = Provider.of<CourseProvider>(context, listen: false);
    registrationProvider =
        Provider.of<RegistrationProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchInitialData();
      await getDominantColor();
    });
  }

  Future<void> fetchInitialData() async {
    setState(() {
      isLoading = true;
    });

    final totalQuestions = await _apiQuiz.fetchTotalQuestions(widget.courseId);
    totalQuestionQuiz = totalQuestions;

    try {
      await Future.wait([
        courseProvider.getFirstVideoUrl(widget.categoryId, widget.courseId),
        courseProvider.fetchCourseAndAdminById(
            widget.categoryId, widget.courseId),
        lectureProvider.getSections(widget.categoryId, widget.courseId)
      ]);
      _initializeVideoController(courseProvider.firstVideoUrl);

      if (courseProvider.course == null ||
          courseProvider.course!.imageUrl.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getDominantColor() async {
    final course = courseProvider.course;
    if (course != null && course.imageUrl.isNotEmpty) {
      try {
        PaletteGenerator paletteGenerator = await _generatePalatteColor(course);
        setState(() {
          dominantColor = paletteGenerator.dominantColor?.color ?? Colors.grey;
        });
      } catch (e) {
        setState(() {
          dominantColor = Colors.grey;
        });
      }
    } else {
      setState(() {
        dominantColor = Colors.grey;
      });
    }
  }

  Future<PaletteGenerator> _generatePalatteColor(CourseModel course) async {
    if (course.imageUrl.isEmpty) {
      return PaletteGenerator.fromColors([PaletteColor(Colors.grey, 2)]);
    }
    return await PaletteGenerator.fromImageProvider(
      CachedNetworkImageProvider(course.imageUrl),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isBottomSheetVisible) {
        setState(() {
          _isBottomSheetVisible = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isBottomSheetVisible) {
        setState(() {
          _isBottomSheetVisible = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
          body: Consumer2<CourseProvider, RegistrationProvider>(
            builder: (context, courseProvider, registrationProvider, child) {
              final course = courseProvider.course;
              final admin = courseProvider.admin;

              if (isLoading) {
                return const BuildCourseDetailShimmer();
              } else if (course == null || admin == null) {
                return const Center(
                  child: Text(
                    'Failed to load course details',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }

              return Scrollbar(
                controller: _scrollController,
                interactive: true,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverAppBar(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      leading: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () async {
                          if (registrationProvider.hasShownDialog == true) {
                            bool? shouldExit = await showCustomDialog(
                              context,
                              'Registration in Progress',
                              'You are currently registering. If you exit now, your registration progress may be lost. Do you want to continue?',
                            );
                            if (shouldExit == true) {
                              registrationProvider.isCancelled = true;
                            }
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: dominantColor.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_ios, size: 16),
                        ),
                      ),
                      expandedHeight: converheight,
                      flexibleSpace:
                          buildFlexibleSpaceBar(context, courseProvider),
                    ),
                    _buildDetails(localization, course, admin),
                  ],
                ),
              );
            },
          ),
          bottomSheet: _buildBottomSheet(localization, isDarkMode)),
    );
  }

  FlexibleSpaceBar buildFlexibleSpaceBar(
      BuildContext context, CourseProvider courseProvider) {
    return FlexibleSpaceBar(
      collapseMode: CollapseMode.parallax,
      background: _buildBackgroundWidget(),
    );
  }

  Widget _buildBackgroundWidget() {
    if (courseProvider.firstVideoUrl != null) {
      return betterPlayerController != null
          ? BetterPlayer(controller: betterPlayerController!)
          : const SizedBox.shrink();
    } else if (courseProvider.course?.imageUrl != null &&
        courseProvider.course!.imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: courseProvider.course!.imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey[300] ?? Colors.grey,
          highlightColor: Colors.grey[100] ?? Colors.grey,
          child: Container(
            color: Colors.white,
          ),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else {
      return Container(
        color: Colors.grey,
      );
    }
  }

  SliverToBoxAdapter _buildDetails(
      AppLocalizations localization, CourseModel course, AdminModel admin) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    course.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  localization.lectureBy(admin.name),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          const Divider(
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${localization.lectures} : $totalVideos'),
                Text('${localization.quiz} : $totalQuestionQuiz'),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text('${localization.students} : $totalQuestionQuiz')),
          ),
          const SizedBox(height: 5),
          const Divider(
            color: Colors.grey,
          ),
          // Padding(
          //   padding: EdgeInsets.only(
          //       bottom: MediaQuery.of(context).padding.bottom + 100),
          //   child:
          //       DescriptionWidget(videoDescription: course.description ?? ''),
          // ),
          DescriptionWidget(videoDescription: course.description ?? ''),

          BuildCourseCurriculum(
            lectureProvider: lectureProvider,
          )
        ],
      ),
    );
  }

  Widget _buildBottomSheet(AppLocalizations localization, bool isDarkMode) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isBottomSheetVisible ? 120 : 0,
      child: Consumer2<CourseProvider, RegistrationProvider>(
        builder: (context, courseProvider, registrationProvider, child) {
          final course = courseProvider.course;
          final admin = courseProvider.admin;
          if (course == null || admin == null || isLoading) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(top: 20, right: 10, left: 10),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        course.price == 0
                            ? localization.Free
                            : '\$ ${course.price!.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          color: course.price == 0
                              ? Colors.red
                              : Theme.of(context).textTheme.bodyMedium!.color,
                          fontWeight: course.price == 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  course.price != 0
                      ? Row(
                          children: [
                            Expanded(
                              child: CustomBtnLoadingWidget(
                                btnText: registrationProvider
                                        .isUserRegisteredForCourse(
                                            widget.courseId)
                                    ? 'Start Course'
                                    : 'Add to cart',
                                onTap: (startLoading, stopLoading,
                                    btnState) async {
                                  await _registrationLogic(
                                      btnState,
                                      startLoading,
                                      registrationProvider,
                                      course,
                                      stopLoading);
                                },
                              ),
                            ),
                            SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(56, 48),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  side: const BorderSide(color: Colors.grey),
                                ),
                                onPressed: () {
                                  if (admin != null && course != null) {
                                    addToCartDialog(course, admin.name);
                                  }
                                },
                                child: Icon(
                                  Icons.favorite_border,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: CustomBtnLoadingWidget(
                                  btnText: registrationProvider
                                          .isUserRegisteredForCourse(
                                              widget.courseId)
                                      ? 'Start Course'
                                      : localization.enrollnow,
                                  onTap: (startLoading, stopLoading,
                                      btnState) async {
                                    if (btnState == ButtonState.idle) {
                                      startLoading();
                                      await registrationProvider.registerUser(
                                        user!.uid,
                                        widget.courseId,
                                        widget.categoryId,
                                        course.title,
                                      );

                                      if (registrationProvider
                                          .isUserRegisteredForCourse(
                                              widget.courseId)) {
                                        if (!registrationProvider
                                            .hasShownDialog) {
                                          bool isWatch =
                                              await showDialogRegisterSuccess(
                                            course.title,
                                          );
                                          if (isWatch) {
                                            navigatorToTopicscreen(
                                                course.title);
                                          }
                                        }
                                      } else {
                                        navigatorToTopicscreen(course.title);
                                      }
                                    } else {
                                      navigatorToTopicscreen(course.title);
                                    }
                                    stopLoading();
                                  }),
                            ),
                            SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(56, 48),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  side: const BorderSide(color: Colors.grey),
                                ),
                                onPressed: () {},
                                child: Icon(
                                  Icons.favorite_border,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _registrationLogic(
      ButtonState btnState,
      Function startLoading,
      RegistrationProvider registrationProvider,
      CourseModel course,
      Function stopLoading) async {
    if (btnState == ButtonState.idle) {
      startLoading();
      if (!registrationProvider.isUserRegisteredForCourse(widget.courseId)) {
        String amount = '${(double.parse("${course.price}") * 100).toDouble()}';
        await StripeService.instance.createPaymentIntent(amount, 'usd');
        await registrationProvider.registerUser(
          user!.uid,
          widget.courseId,
          widget.categoryId,
          course.title,
        );

        if (registrationProvider.isUserRegisteredForCourse(widget.courseId)) {
          if (!registrationProvider.hasShownDialog) {
            bool isWatch = await showDialogRegisterSuccess(course.title);
            if (isWatch) {
              navigatorToTopicscreen(course.title);
            }
          }
        } else {
          navigatorToTopicscreen(course.title);
        }
      } else {
        navigatorToTopicscreen(course.title);
      }
      stopLoading();
    }
  }

  navigatorToTopicscreen(String title) async {
    context.push(RoutesPath.topicScreen, extra: {
      'courseId': widget.courseId,
      'categoryId': widget.categoryId,
      'title': title,
    });
  }

  void addToCartDialog(CourseModel course, String author) {
    final context = navigatorKey.currentState!.context;
    if (context != null) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            titlePadding: const EdgeInsets.symmetric(horizontal: 11),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(author),
                  ),
                  title: Text(
                    maxLines: 3,
                    course.title,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  leading: CachedNetworkImage(
                    imageUrl: course.imageUrl,
                    fit: BoxFit.contain,
                    width: 60,
                    height: 60,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 15)),
                    onPressed: () {},
                    child: const Text(
                      "Go to cart",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Added to cart",
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
                IconButton(
                  splashRadius: 20,
                  onPressed: () {
                    context.pop();
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/icons8-cancel.svg',
                    // ignore: deprecated_member_use
                    color: Colors.grey,
                    height: 20,
                    width: 20,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }
}
