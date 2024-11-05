import '../../di/dependency_injection.dart';
import '../../providers/categories_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/registration_provider.dart';
import '../../providers/user_provider.dart';
import '../user-screens/user_information_screen.dart';
import '../../widgets/tabs/tab_item.dart';
import '../../export/export.dart';
import '../../generated/l10n.dart';
import '../../widgets/categories-widget/category_widget.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  final VoidCallback? onProfileImageTapped;
  final VoidCallback? onSeeAllCoursesTapped;
  final VoidCallback? onNotificationsTapped;

  const MyHomePage(
      {super.key,
      this.onProfileImageTapped,
      this.onSeeAllCoursesTapped,
      this.onNotificationsTapped});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final ScrollController scrollCategories = ScrollController();
  late TabController _tabController;
  late CourseProvider courseController;
  late RegistrationProvider registrationController;
  late UserProvider userController;
  late CategoriesProvider categoriesProvider;
  final User? user = locator<FirebaseAuth>().currentUser;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Save the token to the database
    locator<UserService>().saveTokenToDatabase();

    // Accessing providers without listening to changes
    userController = Provider.of<UserProvider>(context, listen: false);
    courseController = Provider.of<CourseProvider>(context, listen: false);
    categoriesProvider =
        Provider.of<CategoriesProvider>(context, listen: false);
    registrationController =
        Provider.of<RegistrationProvider>(context, listen: false);

    // Initializing the TabController with the correct vsync
    _tabController = TabController(length: 3, vsync: this);

    // Fetch courses after the first frame is rendered
    SchedulerBinding.instance.addPostFrameCallback((_) {
      courseController.fetchCourses();
    });

    // Listen to tab changes and fetch data accordingly
    _tabController.addListener(() {
      if (_tabController.index == 1 &&
          !courseController.hasFetchedRecentCourses) {
        courseController.fetchRecentCourses();
      } else if (_tabController.index == 2 &&
          !courseController.hasFetchedPopularCourses) {
        courseController.fetchPopularCourses();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    scrollCategories.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final localizations = S.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        // notificationPredicate: (notification) {
        //   return 
        // },
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
            icon:  const Icon(IconlyBold.notification,color: Colors.grey,),
            onPressed: widget.onNotificationsTapped,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Consumer<UserProvider>(builder: (context, value, child) {
                if (userController.user != null) {
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
                child: NestedScrollView(
                  key: Keys.nestedScrollViewKey,
                  controller: _scrollController,
                  floatHeaderSlivers: true,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverOverlapAbsorber(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                            context),
                        sliver: SliverAppBar(
                          forceMaterialTransparency: false,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          automaticallyImplyLeading: false,
                          pinned: true,
                          floating: false,
                          forceElevated: innerBoxIsScrolled,
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
                                  scrollController: scrollCategories,
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
                                indicatorSize: TabBarIndicatorSize.tab,
                                isScrollable: true,
                                indicator: const BoxDecoration(
                                    color: Colors.transparent),
                                labelColor: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                unselectedLabelColor:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white70
                                        : Colors.black54,
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
                      ),
                    ];
                  },
                  body: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
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
