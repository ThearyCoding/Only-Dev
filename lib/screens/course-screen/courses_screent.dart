import 'package:e_leaningapp/di/dependency_injection.dart';
import 'package:e_leaningapp/widgets/loadings/custom_smart_refresh.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../export/export.dart';
import '../../generated/l10n.dart';
import '../../providers/admin_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/registration_provider.dart';
import '../../utils/show_error_utils.dart';
import '../../widgets/cards/build_course_card_widget_ui_v2.dart';
import '../../widgets/loadings/build_shimmer_course_card_v2.dart';
class CoursesScreen extends StatefulWidget {
  final String categoryId;
  final String title;
  const CoursesScreen(
      {super.key, required this.categoryId, required this.title});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  User? user = locator<FirebaseAuth>().currentUser;
  late RefreshController _refreshController;
  late CourseProvider courseProvider;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      courseProvider = Provider.of<CourseProvider>(context, listen: false);
      courseProvider.getCoursesByCategory(widget.categoryId);
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          widget.title,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        leading: IconButton(
          tooltip: localization.back,
          splashRadius: 20,
          icon: Icon(
            Icons.arrow_back_ios,
            size: 16,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            courseProvider.courseByCategoryId.clear();
            courseProvider.clearCoursesByCategoryId();
            context.pop();
          },
        ),
      ),
      body:
          Consumer3<CourseProvider, AdminProvider, RegistrationProvider>(
        builder: (context, courseProvider, adminProvider, registrationProvider,
            child) {
          return SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: true,
            header: const CustomizeHeader(),
            footer: CustomizeFooter(
              noDataText: localization.courses,
            ),
            onRefresh: () {
              _refreshController.loadComplete();
              courseProvider.getCoursesByCategory(widget.categoryId,
                  isRefresh: true);
              _refreshController.refreshCompleted();
            },
            onLoading: () async {
              await _refreshController.requestLoading();
              await courseProvider.getCoursesByCategory(widget.categoryId);
              _refreshController.loadComplete();
              if (!courseProvider.hasMoreCourses) {
                showSnackbar(
                  localization.noMoreCoursesToLoad,
                );
                _refreshController.loadNoData();
                return;
              }
            },
            child: courseProvider.isLoadingCourseByCategoryId &&
                    courseProvider.courseByCategoryId.isEmpty
                ? const BuildShimmerCourseCardV2()
                : courseProvider.courseByCategoryId.isEmpty
                    ? Center(
                        child: Text(localization.noCoursesFoundForThisCategory),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        itemCount: courseProvider.courseByCategoryId.length,
                        itemBuilder: (context, index) {
                          final course =
                              courseProvider.courseByCategoryId[index];

                          // Find the admin corresponding to the course's adminId
                          final admin = adminProvider.admins.firstWhere(
                            (admin) => admin.id == course.adminId,
                            orElse: () => AdminModel(
                              id: '',
                              name: 'Unknown',
                              email: '',
                              imageUrl: '',
                            ),
                          );

                          final isRegistered =
                              registrationProvider.registeredCourses.any(
                                  (register) => register.courseId == course.id);

                          // Get the quiz count for this course
                          final quizCount =
                              courseProvider.quizCounts[course.id] ?? 0;

                          return CourseCardV2(
                            course: course,
                            admin: admin,
                            quizCount: quizCount,
                            userId: user!.uid,
                            isRegistered: isRegistered,
                            totalLectures: 20,
                          );
                        },
                      ),
          );
        },
      ),
    );
  }
}
