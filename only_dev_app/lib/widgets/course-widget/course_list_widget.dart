import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../model/user_model.dart';
import 'package:only_dev_app/features/courses/provider/course_list_provider.dart';
import 'package:only_dev_app/features/enrollments/provider/registration_provider.dart';
import 'package:only_dev_app/widgets/loadings-widget/build_shimmer_course_card_v2.dart';
import '../cards/build_course_card_widget_ui_v2.dart';

class CourseListWidget extends StatefulWidget {
  final String categoryId;
  final int index;
  final CourseListProvider allCoursesProvider;
  final RegistrationProvider registrationProvider;

  const CourseListWidget({
    super.key,
    required this.categoryId,
    required this.index,
    required this.allCoursesProvider,
    required this.registrationProvider,
  });

  @override
  CourseListWidgetState createState() => CourseListWidgetState();
}

class CourseListWidgetState extends State<CourseListWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      if (widget.allCoursesProvider.hasMoreData &&
          !widget.allCoursesProvider.isPaginating) {
        widget.allCoursesProvider.fetchCourses(isPagination: true);
      }
    }
  }

  Future<void> _onRefresh() async {
    await widget.allCoursesProvider.refreshCourses();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Consumer<CourseListProvider>(
      builder: (context, value, child) {
        if (widget.allCoursesProvider.categoryLoadingMap[widget.categoryId] ??
            false) {
          return const BuildShimmerCourseCardV2();
        }

        if (widget.allCoursesProvider.courses.isEmpty) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Text(localization.noCoursesAvailable),
                ),
              ),
            ),
          );
        }

        final itemCount = widget.allCoursesProvider.courses.length +
            (widget.allCoursesProvider.isPaginating ? 1 : 0);

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: Scrollbar(
            thumbVisibility: true,
            interactive: true,
            controller: _scrollController,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              key: PageStorageKey<String>(widget.categoryId),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              itemCount: itemCount,
              itemBuilder: (context, idx) {
                if (idx == widget.allCoursesProvider.courses.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  );
                }

                final course = widget.allCoursesProvider.courses[idx];
                final quizCount =
                    widget.allCoursesProvider.quizCounts[course.id] ?? 0;
                final admin = course.instructor ??
                    widget.allCoursesProvider.adminMap[course.adminId] ??
                    UserModel.empty();
                final isRegistered = widget
                    .registrationProvider.registeredCourses
                    .any((register) => register.courseId == course.id);

                return CourseCardV2(
                  course: course,
                  admin: admin,
                  quizCount: quizCount,
                  isRegistered: isRegistered,
                  totalLectures: course.totalLessons ?? 10,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
