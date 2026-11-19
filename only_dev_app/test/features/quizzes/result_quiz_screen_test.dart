import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:only_dev_app/data/repositories/quiz_repository.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:only_dev_app/features/quizzes/view/result_quiz_screen.dart';
import 'package:only_dev_app/features/quizzes/view/review_question_screen.dart';

class StubQuizRepository implements QuizRepository {
  @override
  Future<List<Map<String, dynamic>>> getQuizzesByCourse(String courseId) async => [];
  @override
  Future<Map<String, dynamic>> getQuizDetail(String quizId) async => {};
  @override
  Future<Map<String, dynamic>> submitQuiz(String quizId, Map<String, dynamic> data) async => {};
  @override
  Future<int> fetchTotalQuestions(String courseId) async => 0;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleQuestions = [
    {
      'question': 'Which Riverpod provider is best suited for async operations?',
      'prompt': 'Which Riverpod provider is best suited for async operations?',
      'answer': 'FutureProvider',
      'options': ['FutureProvider', 'StateProvider'],
      'explanation': 'Handles async.',
    },
    {
      'question': 'What is our rule regarding setState?',
      'prompt': 'What is our rule regarding setState?',
      'answer': 'Zero setState in UI views',
      'options': ['Zero setState in UI views', 'Use setState everywhere'],
      'explanation': 'Mandated by Rule 3.',
    },
  ];

  final sampleUserAnswers = ['FutureProvider', 'Zero setState in UI views'];
  final sampleCorrectAnswers = ['FutureProvider', 'Zero setState in UI views'];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    if (locator.isRegistered<SharedPreferences>()) {
      locator.unregister<SharedPreferences>();
    }
    locator.registerSingleton<SharedPreferences>(prefs);

    if (locator.isRegistered<QuizRepository>()) {
      locator.unregister<QuizRepository>();
    }
    locator.registerSingleton<QuizRepository>(StubQuizRepository());
  });

  Widget createSubject({Map<String, dynamic>? submission}) {
    return ProviderScope(
      child: MaterialApp(
        home: ResultQuizScreen(
          questions: sampleQuestions,
          userAnswers: sampleUserAnswers,
          correctAnswers: sampleCorrectAnswers,
          submission: submission,
        ),
      ),
    );
  }

  group('ResultQuizScreen Widget Tests', () {
    testWidgets('renders passing status and metrics when attempt passed', (tester) async {
      await tester.pumpWidget(createSubject(submission: {
        'submission_id': 'sub_123',
        'attempt_number': 1,
        'score_percent': 100,
        'is_passed': true,
        'passing_score_percent': 70,
        'time_taken_seconds': 42,
        'answers': [
          {'is_correct': true},
          {'is_correct': true},
        ],
      }));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Quiz Results'), findsOneWidget);
      expect(find.text('Attempt 1: Passed!'), findsOneWidget);
      expect(find.text('100% correct'), findsOneWidget);
      expect(find.text('2 of 2 questions'), findsOneWidget);
      expect(find.text('42s'), findsOneWidget);
      expect(find.text('Review Questions'), findsOneWidget);
      expect(find.text('Retake Quiz'), findsOneWidget);
      expect(find.text('Back to Course Curriculum'), findsOneWidget);
    });

    testWidgets('renders failed status when attempt did not meet passing score', (tester) async {
      await tester.pumpWidget(createSubject(submission: {
        'submission_id': 'sub_456',
        'attempt_number': 2,
        'score_percent': 50,
        'is_passed': false,
        'passing_score_percent': 70,
        'time_taken_seconds': 95,
        'answers': [
          {'is_correct': true},
          {'is_correct': false},
        ],
      }));
      await tester.pumpAndSettle();

      expect(find.text('Attempt 2: Failed!'), findsOneWidget);
      expect(find.text('50% correct'), findsOneWidget);
      expect(find.text('1 of 2 questions'), findsOneWidget);
      expect(find.text('1m 35s'), findsOneWidget);
    });

    testWidgets('tapping Review Questions navigates to ReviewQuestionScreen', (tester) async {
      await tester.pumpWidget(createSubject(submission: {
        'score_percent': 100,
        'is_passed': true,
      }));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Review Questions'));
      await tester.pumpAndSettle();

      expect(find.byType(ReviewQuestionScreen), findsOneWidget);
      expect(find.text('Review Questions'), findsWidgets);
    });
  });
}
