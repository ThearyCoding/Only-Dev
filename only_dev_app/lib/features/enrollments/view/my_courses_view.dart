import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

import 'package:only_dev_app/core/viewmodel/base_view.dart';
import 'package:only_dev_app/data/models/models.dart';
import 'package:only_dev_app/generated/l10n.dart';
import 'package:only_dev_app/routes/app_routes.dart';
import 'package:only_dev_app/utils/auth_guard_utils.dart';
import 'package:only_dev_app/widgets/cards/course_card_registered.dart';
import '../viewmodel/enrollments_viewmodel.dart';

class MyCoursesView extends StatefulWidget {
  const MyCoursesView({super.key});

  @override
  State<MyCoursesView> createState() => _MyCoursesViewState();
}

class _MyCoursesViewState extends State<MyCoursesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _savedDir = '';
  Set<String> _downloadedVideos = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeDownloads();
  }

  Future<void> _initializeDownloads() async {
    try {
      final directory = await getApplicationSupportDirectory();
      _savedDir = directory.path;
      await _loadDownloadedVideos();
    } catch (_) {}
  }

  Future<void> _loadDownloadedVideos() async {
    try {
      final directory = Directory(_savedDir);
      if (await directory.exists()) {
        final files = directory.listSync();
        if (mounted) {
          setState(() {
            _downloadedVideos = files
                .where((file) => file.path.endsWith('.mp4'))
                .map((file) => file.path.split('/').last)
                .toSet();
          });
        }
      }
    } catch (_) {}
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          splashRadius: 20,
          tooltip: 'Back',
          icon: Icon(
            Icons.arrow_back_ios,
            size: 16,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          localization.myCourses,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        bottom: TabBar(
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            return states.contains(WidgetState.focused)
                ? null
                : Colors.transparent;
          }),
          controller: _tabController,
          indicator: RectangularIndicator(
            bottomLeftRadius: 10,
            bottomRightRadius: 10,
            topLeftRadius: 10,
            topRightRadius: 10,
            verticalPadding: 5,
            horizontalPadding: 5,
            color: Colors.blueAccent.shade400.withOpacity(.3),
          ),
          tabs: [
            Tab(text: localization.ongoing),
            Tab(text: localization.downloaded),
            Tab(text: localization.completed),
          ],
        ),
      ),
      body: !AuthGuard.isAuthenticated()
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.video_library_outlined,
                        size: 40,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Track Your Learning',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sign in to access your enrolled courses, continue where you left off, and view your progress.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 220,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push(RoutesPath.login),
                        icon: const Icon(Icons.login_rounded, size: 18),
                        label: const Text('Sign In / Register'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : BaseView<EnrollmentsViewModel>(
        onModelReady: (model) => model.fetchMyEnrollments(),
        builder: (context, model, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildEnrollmentList(
                context,
                enrollments: model.ongoingEnrollments,
                isLoading: model.isBusy,
                emptyMessage: localization.noRegisteredCoursesFound,
              ),
              _buildDownloadedList(context, localization),
              _buildEnrollmentList(
                context,
                enrollments: model.completedEnrollments,
                isLoading: model.isBusy,
                emptyMessage: localization.noCompletedCoursesFound,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEnrollmentList(
    BuildContext context, {
    required List<EnrollmentModel> enrollments,
    required bool isLoading,
    required String emptyMessage,
  }) {
    if (isLoading && enrollments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (enrollments.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      itemCount: enrollments.length,
      itemBuilder: (ctx, index) {
        final enrollment = enrollments[index];
        final course = enrollment.course ??
            CourseModel(
              id: enrollment.courseId,
              title: 'Course ${enrollment.courseId}',
              imageUrl: '',
              categoryId: '',
              adminId: '',
            );

        final admin = UserModel.empty();

        final totalLessons = course.totalLessons ?? 10;
        final currentLessons = (totalLessons * (enrollment.percentComplete / 100)).round();

        return CourseCardRegistered(
          admin: admin,
          course: course,
          totalLessons: totalLessons,
          currentLessons: currentLessons,
        );
      },
    );
  }

  Widget _buildDownloadedList(BuildContext context, AppLocalizations localization) {
    if (_downloadedVideos.isEmpty) {
      return Center(
        child: Text(
          'No downloaded videos found',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      itemCount: _downloadedVideos.length,
      itemBuilder: (ctx, index) {
        final videoName = _downloadedVideos.elementAt(index);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.offline_pin, color: Colors.green),
            title: Text(videoName),
            subtitle: const Text('Downloaded for offline viewing'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () async {
                final file = File('$_savedDir/$videoName');
                if (await file.exists()) {
                  await file.delete();
                  await _loadDownloadedVideos();
                }
              },
            ),
          ),
        );
      },
    );
  }
}

