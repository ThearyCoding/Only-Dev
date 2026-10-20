import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/widgets/app_widgets/app_image_widget.dart';
import 'package:go_router/go_router.dart';

import 'package:only_dev_app/core/viewmodel/base_view.dart';
import 'package:only_dev_app/data/models/models.dart';
import 'package:only_dev_app/generated/l10n.dart';
import 'package:only_dev_app/features/courses/provider/lecture_provider.dart';
import 'package:only_dev_app/routes/app_routes.dart';
import 'package:only_dev_app/utils/app_toast_utils.dart';
import 'package:only_dev_app/utils/auth_guard_utils.dart';
import 'package:only_dev_app/utils/show_dialog_infor_utils.dart';
import 'package:only_dev_app/widgets/buttons/custom_btn_loading_widget.dart';
import 'package:only_dev_app/widgets/course-widget/build_course_curriculum.dart';
import 'package:only_dev_app/widgets/loadings-widget/build_course_detail_shimmer.dart';
import 'package:only_dev_app/widgets/topic-widget/description_topic_widget.dart';
import '../viewmodel/course_detail_viewmodel.dart';

class CourseDetailView extends ConsumerStatefulWidget {
  final String categoryId;
  final String courseId;
  final CourseModel? initialCourse;

  const CourseDetailView({
    super.key,
    required this.categoryId,
    required this.courseId,
    this.initialCourse,
  });

  @override
  ConsumerState<CourseDetailView> createState() => _CourseDetailViewState();
}

class _CourseDetailViewState extends ConsumerState<CourseDetailView> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _detailsTitleKey = GlobalKey();
  final double _coverHeight = 220.0;

  @override
  void initState() {
    super.initState();
    // Fetch curriculum sections via lectureProvider if available in context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final lectureProvider = ref.read(lectureNotifierProvider);
        lectureProvider.getSections(widget.categoryId, widget.courseId);
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll(CourseDetailViewModel model) {
    if (_detailsTitleKey.currentContext != null) {
      final RenderBox? renderBox =
          _detailsTitleKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        if (position.dy <= kToolbarHeight && !model.showTitleInAppBar) {
          model.setShowTitleInAppBar(true);
        } else if (position.dy > kToolbarHeight && model.showTitleInAppBar) {
          model.setShowTitleInAppBar(false);
        }
      }
    }

    if (_scrollController.hasClients) {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (model.isBottomSheetVisible) {
          model.setBottomSheetVisible(false);
        }
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!model.isBottomSheetVisible) {
          model.setBottomSheetVisible(true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BaseView<CourseDetailViewModel>(
      onModelReady: (model) {
        model.init(widget.courseId, initialCourse: widget.initialCourse);
        _scrollController.addListener(() => _onScroll(model));
      },
      onModelDispose: (model) {
        // ViewModel handles its own cleanup
      },
      builder: (context, model, child) {
        if (model.isBusy && model.course == null) {
          return const Scaffold(body: BuildCourseDetailShimmer());
        }

        final course = model.course;
        if (course == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Course Details')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    model.errorMessage ?? 'Failed to load course details',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => model.init(widget.courseId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          child: Scaffold(
            body: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  stretch: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  leading: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: model.dominantColor.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios, size: 16),
                    ),
                  ),
                  title: model.showTitleInAppBar
                      ? Text(
                          course.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                  expandedHeight: _coverHeight,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: _buildHeaderMedia(course),
                  ),
                ),
                _buildDetails(context, model, course, localization),
              ],
            ),
            bottomSheet: _buildBottomSheet(context, model, course, localization, isDarkMode),
          ),
        );
      },
    );
  }

  Widget _buildHeaderMedia(CourseModel course) {
    return AppImageWidget(
      imageUrl: course.imageUrl,
      fit: BoxFit.cover,
      blurHash: course.blurHash,
      fallbackWidget: Container(
        color: Colors.blueGrey.shade700,
        child: const Center(
          child: Icon(Icons.school, size: 64, color: Colors.white70),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildDetails(
    BuildContext context,
    CourseDetailViewModel model,
    CourseModel course,
    AppLocalizations localization,
  ) {
    LectureProvider? lectureProvider;
    try {
      lectureProvider = ref.watch(lectureNotifierProvider);
    } catch (_) {}

    final totalLectures = model.totalLectures > 0
        ? model.totalLectures
        : (course.totalLessons ?? 0);

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              key: _detailsTitleKey,
              course.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.person_outline, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  localization.lectureBy(course.instructor?.name ?? 'Instructor'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.video_collection_outlined, size: 18, color: Colors.blueAccent),
                    const SizedBox(width: 6),
                    Text('${localization.lectures}: $totalLectures'),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.quiz_outlined, size: 18, color: Colors.orangeAccent),
                    const SizedBox(width: 6),
                    Text('${localization.quiz}: ${model.totalQuizQuestions}'),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.group_outlined, size: 18, color: Colors.teal),
                    const SizedBox(width: 6),
                    Text('${localization.students}: ${course.enrollmentCounts}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          if (course.description != null && course.description!.isNotEmpty)
            DescriptionWidget(videoDescription: course.description!),
          if (model.sections.isNotEmpty)
            BuildCourseCurriculum(sections: model.sections)
          else if (lectureProvider != null && lectureProvider.sections.isNotEmpty)
            BuildCourseCurriculum(lectureProvider: lectureProvider),
          const SizedBox(height: 120), // Bottom padding for sheet
        ],
      ),
    );
  }

  Widget _buildBottomSheet(
    BuildContext context,
    CourseDetailViewModel model,
    CourseModel course,
    AppLocalizations localization,
    bool isDarkMode,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: model.isBottomSheetVisible ? 110 : 0,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, -3),
            blurRadius: 10,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (course.price == null || course.price == 0)
                        ? localization.Free
                        : '\$${course.price!.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: (course.price == null || course.price == 0)
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (model.isEnrolled)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, size: 16, color: Colors.green),
                          SizedBox(width: 4),
                          Text('Enrolled', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomBtnLoadingWidget(
                      btnText: model.isEnrolled
                          ? 'Start Learning'
                          : ((course.price == null || course.price == 0)
                              ? localization.enrollnow
                              : 'Enroll Now'),
                      onTap: (startLoading, stopLoading, btnState) async {
                        if (model.isEnrolled) {
                          _navigateToTopicScreen(context, course.title, model);
                          return;
                        }

                        if (!AuthGuard.isAuthenticated()) {
                          final loggedIn = await AuthGuard.requireAuth(
                            context,
                            title: 'Sign In to Enroll',
                            message: 'Please sign in to enroll in this course and track your learning progress.',
                          );
                          if (!loggedIn) return;
                        }

                        startLoading();
                        final success = await model.enrollInCourse();
                        stopLoading();

                        if (success) {
                          final shouldStart = await showDialogRegisterSuccess(course.title);
                          if (shouldStart && context.mounted) {
                            _navigateToTopicScreen(context, course.title, model);
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(
                          color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
                        ),
                      ),
                      onPressed: () {
                        AppToastUtils.show('Added to Wishlist');
                      },
                      child: Icon(
                        Icons.favorite_border,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToTopicScreen(
    BuildContext context,
    String title,
    CourseDetailViewModel model,
  ) async {
    await context.push(RoutesPath.topicScreen, extra: {
      'courseId': widget.courseId,
      'categoryId': widget.categoryId,
      'title': title,
    });
    if (mounted) {
      model.init(widget.courseId);
    }
  }
}

