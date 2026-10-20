import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import '../../model/user_model.dart';
import '../../widgets/loadings-widget/build_shimmer_course_card_v2.dart';
import '../../widgets/cards/build_course_card_widget_ui_v2.dart';
import '../../di/dependency_injection.dart';

class TabItemLessonsWidget extends ConsumerStatefulWidget {
  final Key uniqueKey;
  const TabItemLessonsWidget(this.uniqueKey, {super.key});

  @override
  ConsumerState<TabItemLessonsWidget> createState() => _TabItemLessonsWidgetState();
}

class _TabItemLessonsWidgetState extends ConsumerState<TabItemLessonsWidget>
    with AutomaticKeepAliveClientMixin {
  final User? user = locator<FirebaseAuth>().currentUser;
  final ScrollController scrollController = ScrollController();
  final Map<String, int> totalLecturesMap = {};

  @override
  bool get wantKeepAlive => true;

  Future<void> _refreshCourses() async {
    await ref.read(courseNotifierProvider).refreshCourses();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final courseProvider = ref.watch(courseNotifierProvider);
    final adminProvider = ref.watch(adminNotifierProvider);
    final registrationProvider = ref.watch(registrationNotifierProvider);

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
                orElse: () => UserModel.empty());
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
  }
}
