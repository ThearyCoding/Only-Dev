import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import '../../di/dependency_injection.dart';
import '../../model/user_model.dart';
import '../../widgets/loadings-widget/build_shimmer_course_card_v2.dart';
import '../../widgets/cards/build_course_card_widget_ui_v2.dart';

class TabItemPopularWidget extends ConsumerStatefulWidget {
  final Key uniqueKey;
  const TabItemPopularWidget(this.uniqueKey, {super.key});

  @override
  ConsumerState<TabItemPopularWidget> createState() => _TabItemPopularWidgetState();
}

class _TabItemPopularWidgetState extends ConsumerState<TabItemPopularWidget>
    with AutomaticKeepAliveClientMixin {
  final User? user = locator<FirebaseAuth>().currentUser;
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final courseProvider = ref.watch(courseNotifierProvider);
    final adminProvider = ref.watch(adminNotifierProvider);
    final registrationProvider = ref.watch(registrationNotifierProvider);

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
  }

  @override
  bool get wantKeepAlive => true;
}
