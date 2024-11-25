import '../../di/dependency_injection.dart';
import '../../export/export.dart';
import '../../providers/admin_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/registration_provider.dart';
import '../../widgets/loadings-widget/build_shimmer_course_card_v2.dart';
import '../../widgets/cards/build_course_card_widget_ui_v2.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TabItemRecentWidget extends StatefulWidget {
  const TabItemRecentWidget({super.key});

  @override
  State<TabItemRecentWidget> createState() => _TabItemRecentWidgetState();
}

class _TabItemRecentWidgetState extends State<TabItemRecentWidget>
    with AutomaticKeepAliveClientMixin<TabItemRecentWidget> {
  late CourseProvider courseProvider;
  late AdminProvider adminProvider;
  late RegistrationProvider registrationProvider;
  final User? user = locator<FirebaseAuth>().currentUser;
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);
  final ScrollController scrollController = ScrollController();
  final Map<String, int> totalLecturesMap = {};
  final UserService userService = locator<UserService>();
  @override
  void initState() {
    super.initState();
    courseProvider = Provider.of<CourseProvider>(context, listen: false);
    adminProvider = Provider.of<AdminProvider>(context, listen: false);
    registrationProvider =
        Provider.of<RegistrationProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchTotalLecturesForAllCourses();
    });
  }

  @override
  dispose() {
    super.dispose();
    scrollController.dispose();
  }

  Future<void> fetchTotalLecturesForAllCourses() async {
    Map<String, int> fetchedTotalLectures = {};
    List<Future<void>> fetchTasks = [];

    for (var course in courseProvider.courses) {
      fetchTasks.add(
        userService
            .getTotalLectures(course.categoryId, course.id)
            .then((lectures) {
          fetchedTotalLectures[course.id] = lectures;
        }),
      );
    }

    await Future.wait(fetchTasks);
    setState(() {
      totalLecturesMap.addAll(fetchedTotalLectures);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<CourseProvider>(builder: (context, value, child) {
      if (courseProvider.isLoadingRecentCourses) {
        return const BuildShimmerCourseCardV2();
      }
      if (courseProvider.recentCourses.isEmpty) {
        return const Center(child: Text('No recent courses found'));
      }

      return NotificationListener(
        onNotification: (Notification notification) {
          ScrollAbsorber.absorbScrollNotification(notification);
          return true;
        },
        child: CustomScrollView(
          cacheExtent: double.infinity,
          controller: scrollController,
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final course = courseProvider.recentCourses[index];
                    final quizCount = courseProvider.quizCounts[course.id] ?? 0;
                    final admin = adminProvider.admins.firstWhere(
                        (admin) => admin.id == course.adminId,
                        orElse: () => AdminModel.empty());
                    final totalLectures = totalLecturesMap[course.id] ?? 0;

                    final isRegistered = registrationProvider.registeredCourses
                        .any((register) => register.courseId == course.id);
                    return CourseCardV2(
                      course: course,
                      admin: admin,
                      quizCount: quizCount,
                      isRegistered: isRegistered,
                      totalLectures: totalLectures,
                    );
                  },
                  childCount: courseProvider.recentCourses.length,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}
