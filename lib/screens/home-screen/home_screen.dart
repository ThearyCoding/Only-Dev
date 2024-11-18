import '../../di/dependency_injection.dart';
import '../../providers/categories_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/registration_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/tabs/custom_tap_material_indicator.dart';
import '../user-screens/user_information_screen.dart';
import '../../export/export.dart';
import '../../generated/l10n.dart';
import '../../widgets/categories-widget/category_widget.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onProfileImageTapped;
  final VoidCallback? onSeeAllCoursesTapped;
  final VoidCallback? onNotificationsTapped;

  const HomePage({
    super.key,
    this.onProfileImageTapped,
    this.onSeeAllCoursesTapped,
    this.onNotificationsTapped,
  });

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final ScrollController _categoriesscrollCategories = ScrollController();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  late PageController _pageController;
  late CourseProvider courseController;
  late RegistrationProvider registrationController;
  late UserProvider userProvider;
  late CategoriesProvider categoriesProvider;
  final User? user = locator<FirebaseAuth>().currentUser;

  @override
  void initState() {
    super.initState();

    locator<UserService>().saveTokenToDatabase();

    userProvider = Provider.of<UserProvider>(context, listen: false);
    courseController = Provider.of<CourseProvider>(context, listen: false);
    categoriesProvider =
        Provider.of<CategoriesProvider>(context, listen: false);
    registrationController =
        Provider.of<RegistrationProvider>(context, listen: false);

    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      courseController.fetchCourses();
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.jumpToPage(_tabController.index);
        _fetchTabData(_tabController.index);
      }
    });

    _pageController.addListener(() {
      int newIndex = _pageController.page!.round();
      if (_tabController.index != newIndex) {
        _tabController.animateTo(newIndex);
        _fetchTabData(newIndex);
      }
    });
  }

  void _fetchTabData(int index) {
    if (index == 1 && !courseController.hasFetchedRecentCourses) {
      courseController.fetchRecentCourses();
    } else if (index == 2 && !courseController.hasFetchedPopularCourses) {
      courseController.fetchPopularCourses();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _categoriesscrollCategories.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          localizations.appTitle,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        leading: IconButton(
          icon: ClipOval(child: Image.asset('assets/logo app.jpg')),
          onPressed: null,
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.zero,
            tooltip: localizations.searchCourses,
            splashRadius: 20,
            onPressed: () {
              context.push(RoutesPath.searchEngineScreen);
            },
            icon: const Icon(
              Icons.search,
              size: 25,
              color: Colors.grey,
            ),
          ),
          IconButton(
            tooltip: localizations.notifications,
            splashRadius: 20,
            padding: EdgeInsets.zero,
            color: Theme.of(context).iconTheme.color,
            icon: const Icon(IconlyBold.notification, color: Colors.grey),
            onPressed: widget.onNotificationsTapped,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Consumer<UserProvider>(builder: (context, value, child) {
                if (userProvider.user != null) {
                  return ProfileImage(onTap: widget.onProfileImageTapped!);
                } else {
                  return const SizedBox();
                }
              })),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double expandedHeight;

          if (constraints.maxWidth < 360) {
            expandedHeight = 180.0;
          } else if (constraints.maxWidth < 480) {
            expandedHeight = 210.0;
          } else if (constraints.maxWidth < 600) {
            expandedHeight = 290.0;
          } else {
            expandedHeight = 320.0;
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () => context.push(RoutesPath.searchEngineScreen),
                  borderRadius: BorderRadius.circular(10),
                  child: Ink(
                    width: MediaQuery.of(context).size.width - 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search,
                            size: 24,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            localizations.searchCourses,
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Scrollbar(
                  interactive: true,
                  controller: _scrollController,
                  child: NestedScrollView(
                    controller: _scrollController,
                    floatHeaderSlivers: true,
                    key: Keys.nestedScrollViewKey,
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        SliverOverlapAbsorber(
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                                  context),
                          sliver: SliverAppBar(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            pinned: true,
                            expandedHeight: expandedHeight + 50,
                            flexibleSpace: FlexibleSpaceBar(
                              collapseMode: CollapseMode.pin,
                              background: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const BannerWidget(),
                                  ),
                                  CategoryWidget(
                                    categoriesProvider: categoriesProvider,
                                    scrollController:
                                        _categoriesscrollCategories,
                                  )
                                ],
                              ),
                            ),
                            bottom: PreferredSize(
                              preferredSize: const Size.fromHeight(0),
                              child: Container(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                child: TabBar(
                                  controller: _tabController,
                                  splashFactory: NoSplash.splashFactory,
                                  overlayColor:
                                      WidgetStateProperty.resolveWith<Color?>(
                                          (Set<WidgetState> states) {
                                    return states.contains(WidgetState.focused)
                                        ? null
                                        : Colors.transparent;
                                  }),
                                  indicatorSize: TabBarIndicatorSize.label,
                                  indicator: MaterialIndicator(
                                    height: 3,
                                    topLeftRadius: 0,
                                    topRightRadius: 0,
                                    bottomLeftRadius: 5,
                                    bottomRightRadius: 5,
                                    horizontalPadding: 10,
                                    color: Colors.blue.shade300,
                                    verticalPadding:
                                        AppLocalizations.of(context).khmer ==
                                                'ខ្មែរ'
                                            ? 7
                                            : 10,
                                    tabPosition: TabPosition.bottom,
                                  ),
                                  indicatorColor: Colors.blueAccent[500],
                                  isScrollable: true,
                                  tabs: [
                                    // TabItem(
                                    //   title: localizations.lessons,
                                    //   count: courseController.courses.length,
                                    // ),
                                    // TabItem(
                                    //   title: localizations.recentLessons,
                                    //   count:
                                    //       courseController.recentCourses.length,
                                    // ),
                                    // TabItem(
                                    //   title: localizations.popularLessons,
                                    //   count:
                                    //       courseController.popularCourses.length,
                                    // ),

                                    Tab(
                                      text: localizations.lessons,
                                    ),
                                    Tab(
                                      text: localizations.recentLessons,
                                    ),
                                    Tab(text: localizations.popularLessons)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ];
                    },
                    body: PageView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _pageController,
                      children: const [
                        TabItemLessonsWidget(),
                        TabItemRecentWidget(),
                        TabItemPopularWidget(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
