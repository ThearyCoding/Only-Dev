import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:only_dev_app/core/app_style.dart';

import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/features/courses/provider/categories_provider.dart';
import 'package:only_dev_app/features/courses/provider/course_provider.dart';
import 'package:only_dev_app/features/enrollments/provider/registration_provider.dart';
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
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  final ScrollController _categoriesscrollCategories = ScrollController();
  final ScrollController _scrollController = ScrollController();
  late CourseProvider courseController;
  late RegistrationProvider registrationController;
  late CategoriesProvider categoriesProvider;
  final User? user = locator<FirebaseAuth>().currentUser;
  late final TabController _tabController;

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
            tooltip: localizations.notifications,
            splashRadius: 20,
            padding: EdgeInsets.zero,
            color: Theme.of(context).iconTheme.color,
            icon: const Icon(IconlyBold.notification, color: Colors.grey),
            onPressed: () {
              ref.read(bottomNavIndexProvider.notifier).state = 2;
              ref.read(notificationNotifierProvider).markAllAsRead();
            },
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Consumer(builder: (context, ref, child) {
                final user = ref.watch(userNotifierProvider).user;
                if (user != null) {
                  return ProfileImage(
                    onTap: () {
                      ref.read(bottomNavIndexProvider.notifier).state = 3;
                    },
                  );
                } else {
                  return TextButton(
                    onPressed: () => context.push(RoutesPath.login),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      backgroundColor:
                          AppStyle.primaryColor.withValues(alpha: 0.15),
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
          return Column(
            children: [
              Expanded(
                child: NestedScrollView(
                  controller: _scrollController,
                  floatHeaderSlivers: true,
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
                          preferredSize: const Size.fromHeight(60),
                          child: Container(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            // iOS-style segmented control: grey track,
                            // equal-width segments, sliding raised pill.
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? AppStyle.darkSurface
                                    : const Color(0xFFF1F2F4),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: TabBar(
                                controller: _tabController,
                                isScrollable: false,
                                labelPadding: EdgeInsets.zero,
                                splashFactory: NoSplash.splashFactory,
                                overlayColor: const WidgetStatePropertyAll(
                                    Colors.transparent),
                                dividerColor: Colors.transparent,
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicator: BoxDecoration(
                                  color: isDarkMode
                                      ? const Color(0xFF3A3A3C)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                          alpha: isDarkMode ? 0.30 : 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                labelColor: AppStyle.primaryColor,
                                unselectedLabelColor: isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                labelStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                unselectedLabelStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                tabs: [
                                  TabItem(title: localizations.lessons),
                                  TabItem(title: localizations.recentLessons),
                                  TabItem(title: localizations.popularLessons),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: const [
                      TabItemLessonsWidget(),
                      TabItemRecentWidget(),
                      TabItemPopularWidget(),
                    ],
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
