import 'package:e_leaningapp/export/curriculum_export.dart';
import 'package:e_leaningapp/widgets/loadings-widget/build_shimmer_course_card_v2.dart';
import 'package:e_leaningapp/widgets/loadings-widget/custom_smart_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../generated/l10n.dart';
import '../../providers/all_courses_provider.dart';
import '../../providers/registration_provider.dart';
import '../../utils/show_error_utils.dart';
import '../cards/build_course_card_widget_ui_v2.dart';

class CourseListWidget extends StatefulWidget {
  final String categoryId;
  final int index;
  final AllCoursesProvider allCoursesProvider;
  final RegistrationProvider registrationProvider;

  const CourseListWidget({
    Key? key,
    required this.categoryId,
    required this.index,
    required this.allCoursesProvider,
    required this.registrationProvider,
  }) : super(key: key);

  @override
  CourseListWidgetState createState() => CourseListWidgetState();
}

class CourseListWidgetState extends State<CourseListWidget> {
  late RefreshController _refreshController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    // Wait a bit to ensure any ongoing build process is completed
    _refreshController.loadComplete();
    await Future.delayed(const Duration(milliseconds: 100));

    await widget.allCoursesProvider.refreshCourses();
    // Notify SmartRefresher that the refresh is completed
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading(AppLocalizations localization) async {
    // Wait a bit to ensure any ongoing build process is completed
    await Future.delayed(const Duration(milliseconds: 100));
    await widget.allCoursesProvider.fetchCourses(isPagination: true);
    if (widget.allCoursesProvider.hasMoreData) {
      // Notify SmartRefresher that loading more data is complete
      _refreshController.loadComplete();
    } else {
      // Notify SmartRefresher that no more data is available
      _refreshController.loadNoData();
      showSnackbar(localization.noMoreCoursesToLoad);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Consumer<AllCoursesProvider>(
      builder: (context, value, child) {
        if (widget.allCoursesProvider.categoryLoadingMap[widget.categoryId] ??
            false) {
          return const BuildShimmerCourseCardV2();
        }

        return Scrollbar(
          thumbVisibility: true,
          interactive: true,
          controller: _scrollController,
          child: SmartRefresher(
            scrollController: _scrollController,
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: true,
            enableTwoLevel: true,
            header: const CustomizeHeader(),
            footer: CustomizeFooter(noDataText: localization.courses),
            onRefresh: _onRefresh,
            onLoading: () async {
              _onLoading(localization);
            },
            child: widget.allCoursesProvider.courses.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        localization.noCoursesAvailable,
                      ),
                    ),
                  )
                : ListView.builder(
                  controller: _scrollController,
                    key: PageStorageKey<String>(widget.categoryId),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    itemCount: widget.allCoursesProvider.courses.length,
                    itemBuilder: (context, idx) {
                      if (idx < 0 ||
                          idx >= widget.allCoursesProvider.courses.length) {
                        return const SizedBox.shrink();
                      }

                      final course = widget.allCoursesProvider.courses[idx];

                      final quizCount =
                          widget.allCoursesProvider.quizCounts[course.id] ?? 0;
                      final admin =
                          widget.allCoursesProvider.adminMap[course.adminId] ??
                              AdminModel.empty();
                      final isRegistered = widget
                          .registrationProvider.registeredCourses
                          .any((register) => register.courseId == course.id);
                      return CourseCardV2(
                        course: course,
                        admin: admin,
                        quizCount: quizCount,
                        isRegistered: isRegistered,
                        totalLectures: 10,
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
