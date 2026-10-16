import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:only_dev_app/core/viewmodel/base_view.dart';
import 'package:only_dev_app/data/models/models.dart';
import 'package:only_dev_app/generated/l10n.dart';
import 'package:only_dev_app/model/admin_model.dart';
import 'package:only_dev_app/utils/app_toast_utils.dart';
import 'package:only_dev_app/widgets/cards/build_course_card_widget_ui_v2.dart';
import 'package:only_dev_app/widgets/loadings-widget/build_shimmer_course_card_v2.dart';
import 'package:only_dev_app/widgets/loadings-widget/custom_smart_refresh.dart';
import '../viewmodel/courses_viewmodel.dart';

class CoursesView extends StatefulWidget {
  final String categoryId;
  final String title;

  const CoursesView({
    super.key,
    required this.categoryId,
    required this.title,
  });

  @override
  State<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<CoursesView> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
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
          onPressed: () => context.pop(),
        ),
      ),
      body: BaseView<CoursesViewModel>(
        onModelReady: (model) {
          model.fetchCourses(category: widget.categoryId);
        },
        builder: (context, model, child) {
          return SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: true,
            header: const CustomizeHeader(),
            footer: CustomizeFooter(noDataText: localization.courses),
            onRefresh: () async {
              await model.fetchCourses(category: widget.categoryId, refresh: true);
              _refreshController.refreshCompleted();
              _refreshController.resetNoData();
            },
            onLoading: () async {
              final hasMore = await model.loadMoreCourses();
              if (hasMore) {
                _refreshController.loadComplete();
              } else {
                AppToastUtils.show(localization.noMoreCoursesToLoad);
                _refreshController.loadNoData();
              }
            },
            child: model.isBusy && model.courses.isEmpty
                ? const BuildShimmerCourseCardV2()
                : model.courses.isEmpty
                    ? Center(
                        child: Text(localization.noCoursesFoundForThisCategory),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        itemCount: model.courses.length,
                        itemBuilder: (context, index) {
                          final course = model.courses[index];
                          final admin = AdminModel(
                            id: course.adminId,
                            name: 'Instructor',
                            email: '',
                            imageUrl: '',
                          );

                          return CourseCardV2(
                            course: course,
                            admin: admin,
                            quizCount: 0,
                            isRegistered: false,
                            totalLectures: course.totalLessons ?? 0,
                          );
                        },
                      ),
          );
        },
      ),
    );
  }
}

