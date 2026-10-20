import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../di/dependency_injection.dart';
import '../../model/user_model.dart';
import 'package:only_dev_app/features/courses/provider/admin_provider.dart';
import 'package:only_dev_app/features/courses/provider/course_provider.dart';
import 'package:only_dev_app/features/enrollments/provider/registration_provider.dart';
import '../../widgets/loadings-widget/build_shimmer_course_card_v2.dart';
import '../../widgets/cards/build_course_card_widget_ui_v2.dart';

class TabItemPopularWidget extends StatefulWidget {
  final Key uniqueKey;
  const TabItemPopularWidget(this.uniqueKey, {super.key});

  @override
  State<TabItemPopularWidget> createState() => _TabItemPopularWidgetState();
}

class _TabItemPopularWidgetState extends State<TabItemPopularWidget>
    with AutomaticKeepAliveClientMixin {
  late CourseProvider courseProvider;
  late AdminProvider adminProvider;
  late RegistrationProvider registrationProvider;
  final User? user = locator<FirebaseAuth>().currentUser;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    courseProvider = Provider.of<CourseProvider>(context, listen: false);
    adminProvider = Provider.of<AdminProvider>(context, listen: false);
    registrationProvider =
        Provider.of<RegistrationProvider>(context, listen: false);

    // // Fetch popular courses when widget is loaded
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   courseProvider.fetchPopularCourses();
    // });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<CourseProvider>(builder: (context, value, child) {
      if (courseProvider.isLoadingPopularCourses) {
        return const BuildShimmerCourseCardV2();
      }
      if (courseProvider.popularCourses.isEmpty) {
        return const Center(child: Text('No popular courses found'));
      }

      return ExtendedVisibilityDetector(
        uniqueKey: widget.uniqueKey,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: courseProvider.popularCourses.length,
          itemBuilder: (context, index) {
            final course = courseProvider.popularCourses[index];
            final quizCount = courseProvider.quizCounts[course.id] ?? 0;
            final admin = adminProvider.admins.firstWhere(
                (admin) => admin.id == course.adminId,
                orElse: () => UserModel.empty());
            final totalLectures = courseProvider.lecturesMap[course.id] ?? 0;
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
        ),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}
