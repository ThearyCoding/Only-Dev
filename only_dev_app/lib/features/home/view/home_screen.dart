import 'package:flutter/material.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:only_dev_app/core/app_style.dart';

import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/features/courses/provider/categories_provider.dart';
import 'package:only_dev_app/features/courses/provider/course_provider.dart';
import 'package:only_dev_app/features/enrollments/provider/registration_provider.dart';
import 'package:only_dev_app/widgets/tabs-widget/custom_tap_material_indicator.dart';
import 'package:only_dev_app/widgets/tabs-widget/tab_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';

import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:only_dev_app/generated/l10n.dart';
import 'package:only_dev_app/routes/app_routes.dart';
import 'package:only_dev_app/widgets/banner-widget/banner_widget.dart';
import 'package:only_dev_app/widgets/tabs-widget/tab_item_lessons_widget.dart';
import 'package:only_dev_app/widgets/tabs-widget/tab_item_popular_widger.dart';
import 'package:only_dev_app/widgets/tabs-widget/tab_item_recent_widget.dart';
import 'package:only_dev_app/widgets/user-profile/profile_image.dart';
import 'package:only_dev_app/widgets/categories-widget/category_widget.dart';
import 'package:flutter/scheduler.dart';

class HomePage extends ConsumerStatefulWidget {
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

class HomePageState extends ConsumerState<HomePage> with TickerProviderStateMixin {
  final ScrollController _categoriesscrollCategories = ScrollController();
  final ScrollController _scrollController = ScrollController();
  late CourseProvider courseController;
  late RegistrationProvider registrationController;
  late CategoriesProvider categoriesProvider;
  final User? user = locator<FirebaseAuth>().currentUser;
  late final TabController _tabController;
  final GlobalKey<ExtendedNestedScrollViewState> _key =
      GlobalKey<ExtendedNestedScrollViewState>();

  @override
  void initState() {
    super.initState();

    courseController = ref.read(courseNotifierProvider);
    categoriesProvider = ref.read(categoriesNotifierProvider);
    registrationController = ref.read(registrationNotifierProvider);

    _tabController = TabController(length: 3, vsync: this);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      courseController.fetchCourses();
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _fetchTabData(_tabController.index);
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
              child: Consumer(builder: (context, ref, child) {
                final user = ref.watch(userNotifierProvider).user;
                if (user != null) {
                  return ProfileImage(onTap: widget.onProfileImageTapped!);
                } else {
                  return TextButton(
                    onPressed: () => context.push(RoutesPath.login),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      backgroundColor: AppStyle.primaryColor.withValues(alpha: 0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: AppStyle.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  );
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
          final double statusBarHeight = MediaQuery.of(context).padding.top;
          final double pinnedHeaderHeight = statusBarHeight + kToolbarHeight;
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
                  child: ExtendedNestedScrollView(
                    pinnedHeaderSliverHeightBuilder: () {
                      return pinnedHeaderHeight;
                    },
                    onlyOneScrollInBody: true,
                    controller: _scrollController,
                    floatHeaderSlivers: true,
                    key: _key,
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        SliverAppBar(
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          pinned: true,
                          automaticallyImplyLeading: false,
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
                                  scrollController: _categoriesscrollCategories,
                                )
                              ],
                            ),
                          ),
                          bottom: PreferredSize(
                            preferredSize: const Size.fromHeight(0),
                            child: Container(
                              color: Theme.of(context).scaffoldBackgroundColor,
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
                                  color: AppStyle.primaryLight,
                                  verticalPadding:
                                      AppLocalizations.of(context).khmer ==
                                              'ខ្មែរ'
                                          ? 7
                                          : 10,
                                  tabPosition: TabPosition.bottom,
                                ),
                                indicatorColor: AppStyle.primaryColor,
                                isScrollable: true,
                                tabs: [
                                  TabItem(
                                    title: localizations.lessons,
                                    count: courseController.courses.length,
                                  ),
                                  TabItem(
                                    title: localizations.recentLessons,
                                    count:
                                        courseController.recentCourses.length,
                                  ),
                                  TabItem(
                                    title: localizations.popularLessons,
                                    count:
                                        courseController.popularCourses.length,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      controller: _tabController,
                      children: const [
                        TabItemLessonsWidget(Key('tab1')),
                        TabItemRecentWidget(Key('tab2')),
                        TabItemPopularWidget(Key('tab3'))
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
