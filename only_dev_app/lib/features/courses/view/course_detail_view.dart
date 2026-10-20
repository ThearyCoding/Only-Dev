import 'package:flutter/material.dart';
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
  final double _coverHeight = 260.0;

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
      if (renderBox != null && renderBox.hasSize) {
        final position = renderBox.localToGlobal(Offset.zero);
        final threshold = kToolbarHeight + MediaQuery.of(context).padding.top;
        if (position.dy <= threshold && !model.showTitleInAppBar) {
          model.setShowTitleInAppBar(true);
        } else if (position.dy > threshold && model.showTitleInAppBar) {
          model.setShowTitleInAppBar(false);
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
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                  size: 20,
                ),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(RoutesPath.home);
                  }
                },
              ),
              title: Text(
                'Course Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                          border: Border.all(
                            color:
                                const Color(0xFFEF4444).withValues(alpha: 0.25),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.cloud_off_rounded,
                            size: 44,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Unable to Load Course',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        model.errorMessage ??
                            'We encountered an issue fetching this course. Please verify your connection or try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.7)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () => model.init(widget.courseId),
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          label: const Text(
                            'Try Again',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(RoutesPath.home);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDarkMode
                                  ? Colors.white24
                                  : Colors.grey.shade300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Go Back',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? Colors.white70
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final primaryColor = Theme.of(context).primaryColor;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                pinned: true,
                stretch: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(RoutesPath.home);
                        }
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                title: model.showTitleInAppBar
                    ? Text(
                        course.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color:
                              isDarkMode ? Colors.white : const Color(0xFF0F172A),
                        ),
                      )
                    : null,
                expandedHeight: _coverHeight,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: _buildHeaderMedia(course),
                ),
              ),
              _buildDetails(context, model, course, localization, isDarkMode),
            ],
          ),
          bottomNavigationBar: _buildBottomActionBar(
            context,
            model,
            course,
            localization,
            isDarkMode,
            primaryColor,
          ),
        );
      },
    );
  }

  Widget _buildHeaderMedia(CourseModel course) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AppImageWidget(
          imageUrl: course.imageUrl,
          fit: BoxFit.cover,
          blurHash: course.blurHash,
          fallbackWidget: Container(
            color: Colors.blueGrey.shade800,
            child: const Center(
              child: Icon(Icons.school_rounded, size: 64, color: Colors.white70),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 90,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildDetails(
    BuildContext context,
    CourseDetailViewModel model,
    CourseModel course,
    AppLocalizations localization,
    bool isDarkMode,
  ) {
    LectureProvider? lectureProvider;
    try {
      lectureProvider = ref.watch(lectureNotifierProvider);
    } catch (_) {}

    final primaryColor = Theme.of(context).primaryColor;
    final totalLectures = model.totalLectures > 0
        ? model.totalLectures
        : (course.totalLessons ?? 0);

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          // Category & Rating Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (course.categoryId.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      course.categoryId.replaceAll('-', ' ').toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: primaryColor,
                      ),
                    ),
                  ),
                if (course.ratingAvg != null && course.ratingAvg! > 0) ...[
                  Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    course.ratingAvg!.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color:
                          isDarkMode ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  if (course.ratingCount != null && course.ratingCount! > 0)
                    Text(
                      ' (${course.ratingCount})',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? Colors.white54
                            : Colors.grey.shade600,
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Course Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              key: _detailsTitleKey,
              course.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                height: 1.3,
                letterSpacing: -0.3,
                color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Instructor Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                AppCircleAvatar(
                  imageUrl: course.instructor?.photoURL,
                  name: course.instructor?.fullName ?? 'Instructor',
                  radius: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.lectureBy(
                            course.instructor?.fullName ?? 'Instructor'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      if (course.instructor?.headline != null &&
                          course.instructor!.headline!.isNotEmpty)
                        Text(
                          course.instructor!.headline!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.white54
                                : const Color(0xFF64748B),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stat Chips Row (All strictly primaryColor and secondary neutrals)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatChip(
                    context,
                    icon: Icons.play_lesson_outlined,
                    label: '${localization.lectures}: $totalLectures',
                    isDarkMode: isDarkMode,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip(
                    context,
                    icon: Icons.quiz_outlined,
                    label: '${localization.quiz}: ${model.totalQuizQuestions}',
                    isDarkMode: isDarkMode,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip(
                    context,
                    icon: Icons.people_outline_rounded,
                    label: '${course.enrollmentCounts}',
                    isDarkMode: isDarkMode,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Course Description
          if (course.description != null && course.description!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'About Course',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                course.description!,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.8)
                      : const Color(0xFF475569),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Curriculum
          if (model.sections.isNotEmpty)
            BuildCourseCurriculum(sections: model.sections)
          else if (lectureProvider != null &&
              lectureProvider.sections.isNotEmpty)
            BuildCourseCurriculum(lectureProvider: lectureProvider),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isDarkMode,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: primaryColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white70 : const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    CourseDetailViewModel model,
    CourseModel course,
    AppLocalizations localization,
    bool isDarkMode,
    Color primaryColor,
  ) {
    final isFree = course.price == null || course.price == 0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.05),
            offset: const Offset(0, -3),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Price or Status Column
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.isEnrolled ? 'Course Status' : 'Price',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? Colors.white54
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (model.isEnrolled)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Enrolled',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        isFree
                            ? localization.Free
                            : '\$${course.price!.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Action Button
              Expanded(
                flex: 6,
                child: CustomBtnLoadingWidget(
                  backgroundColor: primaryColor,
                  borderRadius: 12.0,
                  btnText: model.isEnrolled
                      ? 'Start Learning'
                      : (isFree ? localization.enrollnow : 'Enroll Now'),
                  onTap: (startLoading, stopLoading, btnState) async {
                    if (model.isEnrolled) {
                      _navigateToTopicScreen(context, course.title, model);
                      return;
                    }

                    if (!AuthGuard.isAuthenticated()) {
                      final loggedIn = await AuthGuard.requireAuth(
                        context,
                        title: 'Sign In to Enroll',
                        message:
                            'Please sign in to enroll in this course and track your learning progress.',
                      );
                      if (!loggedIn) return;
                    }

                    startLoading();
                    final success = await model.enrollInCourse();
                    stopLoading();

                    if (success) {
                      final shouldStart =
                          await showDialogRegisterSuccess(course.title);
                      if (shouldStart && context.mounted) {
                        _navigateToTopicScreen(context, course.title, model);
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Wishlist Button
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? Colors.white12 : Colors.grey.shade300,
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.favorite_border_rounded,
                    size: 20,
                    color: isDarkMode
                        ? Colors.white70
                        : const Color(0xFF475569),
                  ),
                  onPressed: () {
                    AppToastUtils.show('Added to Wishlist');
                  },
                ),
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

