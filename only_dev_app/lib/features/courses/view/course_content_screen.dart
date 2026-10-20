import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/features/courses/widgets/course_curriculum_tab_widget.dart';
import 'package:only_dev_app/features/courses/widgets/course_description_sheet.dart';
import 'package:only_dev_app/features/courses/widgets/course_quiz_tab_widget.dart';
import 'package:only_dev_app/features/courses/widgets/course_video_header_widget.dart';
import 'package:only_dev_app/features/courses/widgets/course_video_player_widget.dart';
import 'package:only_dev_app/generated/l10n.dart';
import 'package:only_dev_app/routes/app_routes.dart';

class CourseContentScreen extends ConsumerStatefulWidget {
  final String? title;
  final String? courseId;
  final String? categoryId;

  const CourseContentScreen({
    super.key,
    this.title,
    this.courseId,
    this.categoryId,
  });

  @override
  ConsumerState<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends ConsumerState<CourseContentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PanelController _panelController = PanelController();
  final PageStorageBucket _bucket = PageStorageBucket();

  late CourseContentParams _params;

  @override
  void initState() {
    super.initState();
    _params = CourseContentParams(
      courseId: widget.courseId?.toString() ?? '',
      categoryId: widget.categoryId?.toString() ?? '',
    );

    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref
            .read(courseContentNotifierProvider(_params).notifier)
            .setActiveTab(_tabController.index);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_params.courseId.isNotEmpty) {
        ref.read(courseContentNotifierProvider(_params).notifier).initialize();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          widget.title ?? 'Topics',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          splashRadius: 20,
          tooltip: localization.back,
          icon: Icon(
            size: 16,
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RoutesPath.home);
            }
          },
        ),
      ),
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: 0,
        maxHeight: 600,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        onPanelClosed: () {
          ref.read(courseContentNotifierProvider(_params).notifier).setPanelOpen(false);
        },
        onPanelOpened: () {
          ref.read(courseContentNotifierProvider(_params).notifier).setPanelOpen(true);
        },
        panel: CourseDescriptionSheet(
          params: _params,
          onClose: () {
            _panelController.close();
          },
        ),
        body: Column(
          children: [
            CourseVideoPlayerWidget(params: _params),
            CourseVideoHeaderWidget(
              params: _params,
              onMoreTap: () {
                _panelController.open();
              },
            ),
            TabBar(
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                return states.contains(WidgetState.focused)
                    ? null
                    : Colors.transparent;
              }),
              controller: _tabController,
              indicator: RectangularIndicator(
                color: Colors.blueAccent.shade400.withValues(alpha: 0.3),
              ),
              tabs: const [
                Tab(text: 'Video'),
                Tab(text: 'Practice'),
              ],
            ),
            Expanded(
              child: PageStorage(
                bucket: _bucket,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    CourseCurriculumTabWidget(
                      key: PageStorageKey('curriculum-${widget.courseId}'),
                      params: _params,
                    ),
                    CourseQuizTabWidget(
                      key: PageStorageKey('quiz-${widget.courseId}'),
                      params: _params,
                      title: widget.title ?? '',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
