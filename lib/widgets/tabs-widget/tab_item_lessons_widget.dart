import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';

import '../../providers/admin_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/registration_provider.dart';
import '../../widgets/loadings-widget/build_shimmer_course_card_v2.dart';
import '../../widgets/cards/build_course_card_widget_ui_v2.dart';
import '../../export/export.dart';
import 'package:flutter/material.dart';

class TabItemLessonsWidget extends StatefulWidget {
  final Key uniqueKey;
  const TabItemLessonsWidget(this.uniqueKey, {super.key});

  @override
  State<TabItemLessonsWidget> createState() => _TabItemLessonsWidgetState();
}

class _TabItemLessonsWidgetState extends State<TabItemLessonsWidget>
    with AutomaticKeepAliveClientMixin {
  late CourseProvider courseProvider;
  late AdminProvider adminProvider;
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
    registrationProvider =
        Provider.of<RegistrationProvider>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _refreshCourses() async {
    await courseProvider.refreshCourses();
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
      return ExtendedVisibilityDetector(
        uniqueKey: widget.uniqueKey,
        child: RefreshIndicator(
          onRefresh: _refreshCourses,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: courseProvider.courses.length,
            itemBuilder: (context, index) {
              final course = courseProvider.courses[index];
              final quizCount = courseProvider.quizCounts[course.id] ?? 0;
              final admin = adminProvider.admins.firstWhere(
                  (admin) => admin.id == course.adminId,
                  orElse: () => AdminModel.empty());
              final totalLectures = courseProvider.lecturesMap[course.id] ?? 0;
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
          ),
        ),
      );
    });
  }
}
