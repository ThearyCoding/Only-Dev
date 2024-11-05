import '../screens/other-screen/khqr_payment_page.dart';

import '../screens/other-screen/payment_options_page.dart';
import '../core/global_navigation.dart';
import '../screens/cart-screen/cart_screen.dart';
import '../screens/course-screen/courses_screent.dart';
import '../screens/course-screen/my_courses_screen.dart';
import '../screens/detail_image_screen.dart';
import '../screens/display_post_screen.dart';
import '../screens/notification-screen/dis_enable_notification_screen.dart';
import '../screens/quiz-screen/review_question_screen.dart';
import '../screens/settings-screens/language_selection_screen.dart';
import '../screens/settings-screens/setting_screen.dart';
import '../service/firebase/auth_state_handler.dart';
import 'package:go_router/go_router.dart';
import '../export/export.dart';
import '../screens/user-screens/user_information_screen.dart';
import '../screens/quiz-screen/result_quiz_screen.dart';
part 'routes_path.dart';

class AppRoutes {

  static GoRouter getRouter() {
    return GoRouter(
      initialLocation: RoutesPath.login,
      navigatorKey: navigatorKey,
      routes: [
        GoRoute(path: RoutesPath.khqrpaymentScreen,pageBuilder: (context, state) {
          return const CupertinoPage(child: KhqrPaymentPage());
        },),
        GoRoute(path: RoutesPath.paymentOptionsPage,builder: (context, state) {
          return const PaymentOptionsPage();
        },),
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
            final args = state.extra as Map<String, dynamic>;
            final courseId = args["courseId"];
            final title = args["title"];
            final categoryId = args["categoryId"];
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
            final args = state.extra as Map<String, dynamic>;
            final postId = args["postId"];
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
            final args = state.extra as Map<String, dynamic>? ?? {};
            final UserModel userModel = args['userModel'] as UserModel;
            final User auth = args['auth'] as User;

            return EditProfileInformation(
              userModel: userModel,
              auth: auth,
            );
          },
        ),
        GoRoute(
          path: RoutesPath.detailImageScreen,
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>;
            final imageUrl = args['imageUrl'] as String;
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
              final args = state.extra as Map<String, dynamic>;
              final categoryId = args['cateogoryId'] as String?;
              final title = args['title'] as String?;
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
            final user = state.extra as User;
            if (user != null) {
              return CompleteInformations(user: user);
            } else {
              return const SizedBox.shrink();
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
              return DetailCourseScreen(
                categoryId: categoryId,
                courseId: courseId,
              );
            } else {
              return const Scaffold(
                body: Center(
                    child: Text('Invalid arguments for DetailCourseScreen')),
              );
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
            return TopicsScreen(
              title: courseTitle,
              courseId: courseId,
              categoryId: categoryId,
            );
          },
        ),
        GoRoute(
          name: RoutesPath.languageSelectionScreen,
          path: RoutesPath.languageSelectionScreen,builder: (context, state) {
          return const LanguageSelectionScreen();
        })
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('No route defined for $state')),
      ),
    );
  }
}
