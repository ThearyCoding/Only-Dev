import 'dart:io';
import '../../core/global_navigation.dart';
import '../../di/dependency_injection.dart';
import '../../providers/admin_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/registration_provider.dart';
import '../../widgets/cards/course_card_registered.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';
import '../../export/export.dart';
import '../../generated/l10n.dart';
import '../../utils/show_error_utils.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => MyCoursesScreenState();
}

class MyCoursesScreenState extends State<MyCoursesScreen>
    with SingleTickerProviderStateMixin {
  final User? user = locator<FirebaseAuth>().currentUser;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegistrationProvider>().fetchAllRegistrations(user!.uid);
      loadDownloadedVideos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isdark = Theme.of(context).brightness == Brightness.dark;
    final localization = S.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          splashRadius: 20,
          tooltip: 'Back',
          icon: Icon(
            Icons.arrow_back_ios,
            size: 16,
            color: isdark ? Colors.white : Colors.black,
          ),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          localization.myCourses,
          style: TextStyle(
            color: isdark ? Colors.white : Colors.black,
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
              bottomLeftRadius: 50,
              bottomRightRadius: 50,
              topLeftRadius: 50,
              topRightRadius: 50,
              verticalPadding: 5,
              horizontalPadding: 5,
              color: Colors.blueAccent.shade400.withOpacity(.3)),
          tabs: [
            Tab(text: localization.ongoing),
            Tab(text: localization.downloaded),
            Tab(text: localization.completed),
          ],
        ),
      ),
      body: PageStorage(
        bucket: PageStorageBucket(),
        child: TabBarView(
          controller: _tabController,
          children: [
            buildOngoing(localization),
            buildDownload(localization),
            buildCompleted(localization),
          ],
        ),
      ),
    );
  }

  Widget buildOngoing(S localization) {
    return Consumer<RegistrationProvider>(
      builder: (context, registrationProvider, child) {
        // Get registered course IDs
        final registeredCourseIds = registrationProvider.registeredCourses
            .map((course) => course.courseId)
            .toList();

        // Fetch the registered courses based on the IDs
        final registeredCourses = context
            .read<CourseProvider>()
            .courses
            .where((course) => registeredCourseIds.contains(course.id))
            .toList();

        // Filter out the ongoing courses
        final ongoingCourses = registeredCourses.where((course) {
          final totalLessons =
              registrationProvider.totalLecturesMap[course.id] ?? 0;
          final watchedLessons =
              registrationProvider.watchedLecturesMap[course.id] ?? 0;
          return watchedLessons < totalLessons; // Only ongoing courses
        }).toList();

        // Display appropriate messages
        if (registrationProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (ongoingCourses.isEmpty) {
          return Center(child: Text(localization.noRegisteredCoursesFound));
        }

        return ListView.builder(
          key: PageStorageKey<String>('courseList-$registeredCourseIds'),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          itemCount: ongoingCourses.length,
          shrinkWrap: false,
          itemBuilder: (ctx, index) {
            final course = ongoingCourses[index];

            // Find the admin corresponding to the course's adminId
            final admin = context.read<AdminProvider>().admins.firstWhere(
                  (admin) => admin.id == course.adminId,
                  orElse: () => AdminModel(
                    id: '',
                    name: 'Unknown',
                    email: '',
                    imageUrl: '',
                  ),
                );

            // Get the total and watched lessons for this course
            final totalLessons =
                registrationProvider.totalLecturesMap[course.id] ?? 0;
            final watchedLessons =
                registrationProvider.watchedLecturesMap[course.id] ?? 0;

            return CourseCardRegistered(
              admin: admin,
              course: course,
              totalLessons: totalLessons,
              currentLessons: watchedLessons,
            );
          },
        );
      },
    );
  }

  Widget buildCompleted(S localization) {
    return Consumer<RegistrationProvider>(
      builder: (context, registrationProvider, child) {
        // Get registered course IDs
        final registeredCourseIds = registrationProvider.registeredCourses
            .map((course) => course.courseId)
            .toList();

        // Fetch the registered courses based on the IDs
        final registeredCourses = context
            .read<CourseProvider>()
            .courses
            .where((course) => registeredCourseIds.contains(course.id))
            .toList();

        // Filter out the completed courses
        final completedCourses = registeredCourses.where((course) {
          final totalLessons =
              registrationProvider.totalLecturesMap[course.id] ?? 0;
          final watchedLessons =
              registrationProvider.watchedLecturesMap[course.id] ?? 0;
          return watchedLessons >= totalLessons; // Only completed courses
        }).toList();

        // Display appropriate messages
        if (registrationProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (completedCourses.isEmpty) {
          return Center(child: Text(localization.noCompletedCoursesFound));
        }

        // Return the list of completed courses
        return ListView.builder(
          key: PageStorageKey<String>(
              'completedCoursesList-$registeredCourseIds'),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          itemCount: completedCourses.length,
          shrinkWrap: false,
          itemBuilder: (ctx, index) {
            final course = completedCourses[index];

            // Find the admin corresponding to the course's adminId
            final admin = context.read<AdminProvider>().admins.firstWhere(
                  (admin) => admin.id == course.adminId,
                  orElse: () => AdminModel(
                    id: '',
                    name: 'Unknown',
                    email: '',
                    imageUrl: '',
                  ),
                );

            // Get the total and watched lessons for this course
            final totalLessons =
                registrationProvider.totalLecturesMap[course.id] ?? 0;
            final watchedLessons =
                registrationProvider.watchedLecturesMap[course.id] ?? 0;

            return CourseCardRegistered(
              admin: admin,
              course: course,
              totalLessons: totalLessons,
              currentLessons: watchedLessons,
            );
          },
        );
      },
    );
  }

  Future<void> loadDownloadedVideos() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final List<FileSystemEntity> files = appDocDir.listSync();
    setState(() {
      downloadedVideos = files
          .where((file) => file.path.endsWith('.mp4'))
          .map((file) => file.path.split('/').last.replaceAll('.mp4', ''))
          .toSet();
    });
  }

  Future<void> removeDownloadedVideo(String videoTitle) async {
    try {
      final context = navigatorKey.currentState!.context;

      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDocDir.path}/$videoTitle.mp4';
      final File file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        await loadDownloadedVideos();
        if (context != null) {
          // ignore: use_build_context_synchronously
          showSnackbar(S.of(context).videoRemoved(videoTitle));
        }
      } else {
        if (context != null) {
          // ignore: use_build_context_synchronously
          showSnackbar(S.of(context).videoNotFound(videoTitle));
        }
      }
    } catch (e) {
      if (context != null) {
        // ignore: use_build_context_synchronously
        showSnackbar(S.of(context).failedToRemoveVideo(e));
      }
    }
  }

  Set<String> downloadedVideos = {};
  Widget buildDownload(S localization) {
    return ListView.builder(
      key: const PageStorageKey<String>('courseList-video-download'),
      itemCount: downloadedVideos.length,
      itemBuilder: (context, index) {
        final videoTitle = downloadedVideos.elementAt(index);
        return ListTile(
          title: Text(videoTitle),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              removeDownloadedVideo(videoTitle);
            },
          ),
        );
      },
    );
  }
}
