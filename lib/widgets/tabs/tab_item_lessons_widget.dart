import 'package:e_leaningapp/di/dependency_injection.dart';
import 'package:e_leaningapp/providers/admin_provider.dart';
import 'package:e_leaningapp/providers/course_provider.dart';
import 'package:e_leaningapp/providers/registration_provider.dart';
import 'package:e_leaningapp/widgets/loadings/build_shimmer_course_card_v2.dart';
import 'package:e_leaningapp/widgets/cards/build_course_card_widget_ui_v2.dart';
import 'package:flutter/material.dart';
import 'package:e_leaningapp/export/export.dart';
import 'package:provider/provider.dart';
class TabItemLessonsWidget extends StatefulWidget {
  const TabItemLessonsWidget({super.key});

  @override
  State<TabItemLessonsWidget> createState() => _TabItemLessonsWidgetState();
}

class _TabItemLessonsWidgetState extends State<TabItemLessonsWidget>
    with AutomaticKeepAliveClientMixin<TabItemLessonsWidget> {
  late CourseProvider courseProvider;
  late  AdminProvider adminProvider;
  late RegistrationProvider registrationProvider;
  final User? user = locator<FirebaseAuth>().currentUser;
  final ScrollController scrollController = ScrollController();
  final UserService userService = locator<UserService>();
  final Map<String, int> totalLecturesMap = {};

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
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchTotalLecturesForAllCourses() async {
    Map<String, int> fetchedTotalLectures = {};
    List<Future<void>> fetchTasks = [];

    for (var course in courseProvider.courses) {
      fetchTasks.add(
        userService.getTotalLectures(course.categoryId, course.id).then((lectures) {
          fetchedTotalLectures[course.id] = lectures;
        }),
      );
    }

    await Future.wait(fetchTasks);
    setState(() {
      totalLecturesMap.addAll(fetchedTotalLectures);
    });
  }

  Future<void> _refreshCourses() async {
    await courseProvider.refreshCourses();
    await fetchTotalLecturesForAllCourses();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<CourseProvider>(builder: (context, value, child) {
      if (courseProvider.isLoading) {
        return const BuildShimmerCourseCardV2();
      }
      if (courseProvider.courses.isEmpty) {
        return const Center(child: Text('No courses found'));
      }

      return NotificationListener(
        onNotification: (Notification notification) {
          ScrollAbsorber.absorbScrollNotification(notification);
          return false;
        },
        child: RefreshIndicator(
          onRefresh: _refreshCourses,
          child: CustomScrollView(
            controller: scrollController,
            cacheExtent: double.infinity,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final course = courseProvider.courses[index];
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
                      final isRegistered = registrationProvider.registeredCourses
                          .any((register) => register.courseId == course.id);
                      return CourseCardV2(
                        key: Key(course.id),
                        course: course,
                        admin: admin,
                        quizCount: quizCount,
                        isRegistered: isRegistered,
                        totalLectures: totalLectures,
                      );
                    },
                    childCount: courseProvider.courses.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}
