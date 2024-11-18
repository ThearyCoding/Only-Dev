import 'package:e_leaningapp/di/dependency_injection.dart';
import 'package:e_leaningapp/export/export.dart';
import 'package:e_leaningapp/providers/admin_provider.dart';
import 'package:e_leaningapp/providers/course_provider.dart';
import 'package:e_leaningapp/providers/registration_provider.dart';
import 'package:e_leaningapp/widgets/loadings/build_shimmer_course_card_v2.dart';
import 'package:e_leaningapp/widgets/cards/build_course_card_widget_ui_v2.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TabItemPopularWidget extends StatefulWidget {
  const TabItemPopularWidget({super.key});

  @override
  State<TabItemPopularWidget> createState() => _TabItemPopularWidgetState();
}

class _TabItemPopularWidgetState extends State<TabItemPopularWidget>
    with AutomaticKeepAliveClientMixin<TabItemPopularWidget> {
  late CourseProvider courseProvider;
  late AdminProvider adminProvider;
  late RegistrationProvider registrationProvider;
  final User? user = locator<FirebaseAuth>().currentUser;
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);
  final ScrollController scrollController = ScrollController();
  final Map<String, int> totalLecturesMap = {};
  final UserService userService =locator<UserService>();
  @override
  void initState() {
    super.initState();
    courseProvider = Provider.of<CourseProvider>(context, listen: false);
    adminProvider = Provider.of<AdminProvider>(context, listen: false);
    registrationProvider = Provider.of<RegistrationProvider>(context, listen: false);
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
      if (courseProvider.isLoadingPopularCourses) {
        return const BuildShimmerCourseCardV2();
      }
      if (courseProvider.popularCourses.isEmpty) {
        return const Center(child: Text('No courses found'));
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
                    final course = courseProvider.popularCourses[index];
                    final quizCount = courseProvider.quizCounts[course.id] ?? 0;
                    final admin = adminProvider.admins.firstWhere(
                      (admin) => admin.id == course.adminId,
                      orElse: () => AdminModel(
                        id: '',
                        name: 'Unknown',
                        email: '',
                        imageUrl: '',
                      ),
                    );
                    final totalLectures = totalLecturesMap[course.id] ?? 0;
                    final isRegistered = registrationProvider
                        .registeredCourses
                        .any((register) => register.courseId == course.id);
                    return CourseCardV2(
                      course: course,
                      admin: admin,
                      quizCount: quizCount,
                      isRegistered: isRegistered,
                      totalLectures: totalLectures,
                    );
                  },
                  childCount: courseProvider.popularCourses.length,
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
