import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:only_dev_app/core/viewmodel/base_view.dart';
import 'package:only_dev_app/data/models/models.dart';
import 'package:only_dev_app/generated/l10n.dart';
import 'package:only_dev_app/utils/app_toast_utils.dart';
import 'package:only_dev_app/widgets/cards/build_course_card_widget_ui_v2.dart';
import 'package:only_dev_app/widgets/loadings-widget/build_shimmer_course_card_v2.dart';
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
  final ScrollController _scrollController = ScrollController();
  CoursesViewModel? _viewModel;

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
      final vm = _viewModel;
      if (vm != null && vm.hasMoreCourses && !vm.isLoadingMore) {
        vm.loadMoreCourses().then((hasMore) {
          if (!hasMore && mounted) {
            final localization = AppLocalizations.of(context);
            AppToastUtils.show(localization.noMoreCoursesToLoad);
          }
        });
      }
    }
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
          _viewModel = model;
          model.fetchCourses(category: widget.categoryId);
        },
        builder: (context, model, child) {
          _viewModel = model;

          if (model.isBusy && model.courses.isEmpty) {
            return const BuildShimmerCourseCardV2();
          }

          if (model.courses.isEmpty) {
            return RefreshIndicator(
              onRefresh: () =>
                  model.fetchCourses(category: widget.categoryId, refresh: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Text(localization.noCoursesFoundForThisCategory),
                  ),
                ),
              ),
            );
          }

          final itemCount = model.courses.length + (model.isLoadingMore ? 1 : 0);

          return RefreshIndicator(
            onRefresh: () =>
                model.fetchCourses(category: widget.categoryId, refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (index == model.courses.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  );
                }

                final course = model.courses[index];
                final admin = UserModel.empty();

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
