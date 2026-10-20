import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/global_navigation.dart';
import '../di/dependency_injection.dart';
import 'package:only_dev_app/features/cart/view/cart_screen.dart';
import 'package:only_dev_app/features/courses/view/course_content_screen.dart';
import 'package:only_dev_app/features/courses/view/courses_screen.dart';
import 'package:only_dev_app/features/courses/view/course_detail_screen.dart';
import 'package:only_dev_app/features/enrollments/view/my_courses_screen.dart';
import 'package:only_dev_app/features/posts/view/display_post_screen.dart';
import 'package:only_dev_app/features/common/view/error_screen.dart';
import 'package:only_dev_app/features/home/view/main_screen.dart';
import 'package:only_dev_app/features/notifications/view/dis_enable_notification_screen.dart';
import 'package:only_dev_app/features/common/view/detail_image_screen.dart';
import 'package:only_dev_app/features/cart/view/khqr_payment_page.dart';
import 'package:only_dev_app/features/cart/view/payment_options_page.dart';
import 'package:only_dev_app/features/quizzes/view/quiz_page.dart';
import 'package:only_dev_app/features/quizzes/view/quiz_result_screen.dart';
import 'package:only_dev_app/features/quizzes/view/result_quiz_screen.dart';
import 'package:only_dev_app/features/quizzes/view/review_question_screen.dart';
import 'package:only_dev_app/features/search/view/search_engine_screen.dart';
import 'package:only_dev_app/features/settings/view/language_selection_screen.dart';
import 'package:only_dev_app/features/settings/view/setting_screen.dart';
import 'package:only_dev_app/features/profile/view/complete_info_screen.dart';
import 'package:only_dev_app/features/profile/view/update_profile_screen.dart';
import '../service/firebase/auth_state_handler.dart';

part 'routes_path.dart';
part 'route_name.dart';

class AppRoutes {
  static GoRouter getRouter() {
    return GoRouter(
      initialLocation: RoutesPath.login,
      navigatorKey: navigatorKey,
      routes: [
        GoRoute(
          path: RoutesPath.khqrpaymentScreen,
          pageBuilder: (context, state) {
            return const CupertinoPage(child: KhqrPaymentPage());
          },
        ),
        GoRoute(
          path: RoutesPath.paymentOptionsPage,
          builder: (context, state) {
            return const PaymentOptionsPage();
          },
        ),
        GoRoute(
          path: RoutesPath.reviewquestionscreen,
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;

            if (args == null) {
              return const SizedBox();
            }

            final questions = args['questions'] as List<Map<String, dynamic>>?;
            final userAnswers = args['userAnswers'] as List<String>?;
            final correctAnswers = args['correctAnswers'] as List<String>?;
            if (questions != null &&
                userAnswers != null &&
                correctAnswers != null) {
              return ReviewQuestionScreen(
                questions: questions,
                userAnswers: userAnswers,
                correctAnswers: correctAnswers,
              );
            } else {
              return const SizedBox();
            }
          },
        ),
        GoRoute(
          path: RoutesPath.resultquizscreen,
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;

            if (args == null) {
              return const SizedBox();
            }
            final questions = args['questions'] as List<Map<String, dynamic>>?;
            final userAnswers = args['userAnswers'] as List<String>?;
            final correctAnswers = args['correctAnswers'] as List<String>?;
            if (questions != null &&
                userAnswers != null &&
                correctAnswers != null) {
              return ResultQuizScreen(
                questions: questions,
                userAnswers: userAnswers,
                correctAnswers: correctAnswers,
              );
            } else {
              return const SizedBox();
            }
          },
        ),
        GoRoute(
          path: RoutesPath.resultscreen,
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;

            if (args == null) {
              return const SizedBox();
            }

            final questions = args['questions'] as List<Map<String, dynamic>>?;
            final userAnswers = args['userAnswers'] as List<String>?;
            final correctAnswers = args['correctAnswers'] as List<String>?;

            if (questions != null &&
                userAnswers != null &&
                correctAnswers != null) {
              return ResultPage(
                questions: questions,
                userAnswers: userAnswers,
                correctAnswers: correctAnswers,
              );
            } else {
              return const SizedBox();
            }
          },
        ),
        GoRoute(
          path: RoutesPath.quizscreen,
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            final courseId = args?["courseId"] ?? '';
            final title = args?["title"] ?? '';
            final categoryId = args?["categoryId"] ?? '';
            return QuizPage(
                courseId: courseId, courseTitle: title, categoryId: categoryId);
          },
        ),
        GoRoute(
          path: RoutesPath.cartscreen,
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: RoutesPath.settingscreen,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: RoutesPath.postDetailsScreen,
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            final postId = args?["postId"] ?? '';
            return PostDetailsScreen(postId: postId);
          },
        ),
        GoRoute(
          path: RoutesPath.myCoursesScreen,
          builder: (context, state) => const MyCoursesScreen(),
        ),
        GoRoute(
          path: RoutesPath.editProfileInformation,
          builder: (context, state) {
            return const EditProfileInformation();
          },
        ),
        GoRoute(
          path: RoutesPath.detailImageScreen,
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            final imageUrl = args?['imageUrl'] as String? ?? '';
            return DetailImageScreen(imageUrl: imageUrl);
          },
        ),
        GoRoute(
          path: RoutesPath.isEnableNotifications,
          builder: (context, state) => const DisEnableNotificationScreen(),
        ),
        GoRoute(
            path: RoutesPath.searchEngineScreen,
            builder: (context, state) => const SearchEnginePage()),
        GoRoute(
            path: RoutesPath.courseScreen,
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>?;
              final categoryId = args?['cateogoryId'] as String?;
              final title = args?['title'] as String?;
              return CoursesScreen(
                  categoryId: categoryId ?? '', title: title ?? '');
            }),
        GoRoute(
          path: RoutesPath.login,
          builder: (context, state) => const AuthStateHandler(),
        ),
        GoRoute(
          path: RoutesPath.completeInfo,
          builder: (context, state) {
            final user = (state.extra as User?) ?? locator<FirebaseAuth>().currentUser;
            if (user != null) {
              return CompleteInformations(user: user);
            } else {
              return const AuthStateHandler();
            }
          },
        ),
        GoRoute(
          path: RoutesPath.home,
          builder: (context, state) => const MainPage(),
        ),
        GoRoute(
          path: RoutesPath.detailCourseScreen,
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            final categoryId = args?['categoryId'] as String?;
            final courseId = args?['courseId'] as String?;
            if (categoryId != null && courseId != null) {
              return CourseDetailScreen(
                categoryId: categoryId,
                courseId: courseId,
              );
            } else {
              return ErrorScreen(message: state.name ?? "");
            }
          },
        ),
        GoRoute(
          path: RoutesPath.topicScreen,
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            final courseTitle = args?['title'] as String?;
            final courseId = args?['courseId'] as String?;
            final categoryId = args?['categoryId'] as String?;
            return CourseContentScreen(
              title: courseTitle,
              courseId: courseId,
              categoryId: categoryId,
            );
          },
        ),
        GoRoute(
            name: RoutesPath.languageSelectionScreen,
            path: RoutesPath.languageSelectionScreen,
            builder: (context, state) {
              return const LanguageSelectionScreen();
            }),
      ],
      errorBuilder: (context, state) => ErrorScreen(message: state.name ?? ""),
    );
  }
}
