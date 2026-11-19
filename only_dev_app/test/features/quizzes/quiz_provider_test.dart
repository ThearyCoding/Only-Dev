import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:only_dev_app/data/repositories/quiz_repository.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:only_dev_app/features/quizzes/provider/quiz_provider.dart';

class FakeQuizRepository implements QuizRepository {
  bool shouldThrowFetch = false;
  bool shouldThrowSubmit = false;
  Map<String, dynamic>? lastSubmittedPayload;
  String? lastSubmittedQuizId;

  List<Map<String, dynamic>> sampleQuizzes = [
    {
      '_id': 'quiz_flutter_101',
      'title': 'Flutter & Riverpod Knowledge Evaluation',
      'course_id': 'course_flutter_1',
      'passing_score_percent': 70,
      'time_limit_minutes': 15,
      'max_attempts_allowed': 3,
      'questions': [
        {
          '_id': 'q_1',
          'prompt': 'Which Riverpod provider is best suited for async operations?',
          'points': 10,
          'options': [
            {'id': 'opt_1', 'text': 'FutureProvider', 'is_correct': true, 'explanation': 'Handles async.'},
            {'id': 'opt_2', 'text': 'StateProvider', 'is_correct': false, 'explanation': 'For primitives.'},
          ],
        },
        {
          '_id': 'q_2',
          'prompt': 'What is our rule regarding setState?',
          'points': 10,
          'options': [
            {'id': 'opt_1', 'text': 'Zero setState in UI views', 'is_correct': true, 'explanation': 'Mandated by Rule 3.'},
            {'id': 'opt_2', 'text': 'Use setState everywhere', 'is_correct': false, 'explanation': 'Causes leaks.'},
          ],
        },
      ],
    },
  ];

  @override
  Future<List<Map<String, dynamic>>> getQuizzesByCourse(String courseId) async {
    if (shouldThrowFetch) {
      throw Exception('Network error fetching quizzes');
    }
    return sampleQuizzes;
  }

  @override
  Future<Map<String, dynamic>> getQuizDetail(String quizId) async {
    return sampleQuizzes.first;
  }

  @override
  Future<Map<String, dynamic>> submitQuiz(String quizId, Map<String, dynamic> data) async {
    lastSubmittedQuizId = quizId;
    lastSubmittedPayload = data;

    if (shouldThrowSubmit) {
      throw Exception('Network error submitting quiz attempt');
    }

    return {
      'submission_id': 'sub_record_999',
      'attempt_number': 1,
      'total_score': 20,
      'max_possible_score': 20,
      'score_percent': 100,
      'passing_score_percent': 70,
      'is_passed': true,
      'time_taken_seconds': 35,
      'answers': [
        {'question_id': 'q_1', 'selected_option_ids': ['opt_1'], 'is_correct': true, 'points_awarded': 10},
        {'question_id': 'q_2', 'selected_option_ids': ['opt_1'], 'is_correct': true, 'points_awarded': 10},
      ],
    };
  }

  @override
  Future<int> fetchTotalQuestions(String courseId) async {
    return 2;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeQuizRepository fakeQuizRepository;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    if (locator.isRegistered<SharedPreferences>()) {
      locator.unregister<SharedPreferences>();
    }
    locator.registerSingleton<SharedPreferences>(prefs);

    fakeQuizRepository = FakeQuizRepository();
    if (locator.isRegistered<QuizRepository>()) {
      locator.unregister<QuizRepository>();
    }
    locator.registerSingleton<QuizRepository>(fakeQuizRepository);
  });

  tearDown(() {
    if (locator.isRegistered<QuizRepository>()) {
      locator.unregister<QuizRepository>();
    }
  });

  group('QuizProvider Unit Tests', () {
    test('Initial state is idle with default countdown timer and indices', () {
      final provider = QuizProvider();
      expect(provider.questions, isEmpty);
      expect(provider.currentQuestionIndex, equals(0));
      expect(provider.selectedAnswer, isEmpty);
      expect(provider.userAnswers, isEmpty);
      expect(provider.time, equals(20));
      expect(provider.isQuizCompleted, isFalse);
      expect(provider.isFetching, isFalse);
      expect(provider.isSubmitting, isFalse);
      expect(provider.lastSubmissionResult, isNull);
    });

    test('fetchQuestions populates questions, options, rawOptions, and answers', () async {
      final provider = QuizProvider();
      provider.setcourseId = 'course_flutter_1';

      await provider.fetchQuestions('course_flutter_1');

      expect(provider.isFetching, isFalse);
      expect(provider.questions.length, equals(2));
      expect(provider.defaultQuizId, equals('quiz_flutter_101'));
      expect(provider.passingScorePercent, equals(70));
      expect(provider.timeLimitMinutes, equals(15));
      expect(provider.maxAttemptsAllowed, equals(3));

      final firstQ = provider.questions[0];
      expect(firstQ['prompt'], equals('Which Riverpod provider is best suited for async operations?'));
      expect(firstQ['question'], equals('Which Riverpod provider is best suited for async operations?'));
      expect(firstQ['answer'], equals('FutureProvider'));
      expect(firstQ['explanation'], equals('Handles async.'));
      expect(firstQ['options'], contains('FutureProvider'));
      expect(firstQ['options'], contains('StateProvider'));

      final rawOpts = firstQ['rawOptions'] as List;
      expect(rawOpts.length, equals(2));
      expect(rawOpts[0]['id'], equals('opt_1'));
      expect(rawOpts[0]['is_correct'], isTrue);
    });

    test('selecting answer updates selectedAnswer and notifies listeners', () {
      final provider = QuizProvider();
      bool notified = false;
      provider.addListener(() => notified = true);

      provider.selectedAnswer = 'FutureProvider';

      expect(provider.selectedAnswer, equals('FutureProvider'));
      expect(notified, isTrue);
    });

    test('progression from Q1 to Q2 records answer and updates index', () async {
      final provider = QuizProvider();
      await provider.fetchQuestions('course_flutter_1');

      provider.selectedAnswer = 'FutureProvider';
      await provider.goToNextQuestion();

      expect(provider.currentQuestionIndex, equals(1));
      expect(provider.userAnswers.length, equals(1));
      expect(provider.userAnswers[0], equals('FutureProvider'));
      expect(provider.selectedAnswer, isEmpty);
    });

    test('going back to previous question restores previously chosen answer', () async {
      final provider = QuizProvider();
      await provider.fetchQuestions('course_flutter_1');

      provider.selectedAnswer = 'FutureProvider';
      await provider.goToNextQuestion();

      expect(provider.currentQuestionIndex, equals(1));

      provider.goToPreviousQuestion();

      expect(provider.currentQuestionIndex, equals(0));
      expect(provider.selectedAnswer, equals('FutureProvider'));
    });

    test('answering final question submits attempt to backend with correct payload', () async {
      final provider = QuizProvider();
      await provider.fetchQuestions('course_flutter_1');

      // Answer question 1
      provider.selectedAnswer = 'FutureProvider';
      await provider.goToNextQuestion();

      // Answer question 2 (last question)
      provider.selectedAnswer = 'Zero setState in UI views';
      await provider.goToNextQuestion();

      expect(provider.isQuizCompleted, isTrue);
      expect(provider.isSubmitting, isFalse);

      // Verify backend call occurred
      expect(fakeQuizRepository.lastSubmittedQuizId, equals('quiz_flutter_101'));
      expect(fakeQuizRepository.lastSubmittedPayload, isNotNull);

      final submittedAnswers = fakeQuizRepository.lastSubmittedPayload!['answers'] as List;
      expect(submittedAnswers.length, equals(2));
      expect(submittedAnswers[0]['questionId'], equals('q_1'));
      expect(submittedAnswers[0]['selectedOptionIds'], equals(['opt_1']));
      expect(submittedAnswers[1]['questionId'], equals('q_2'));
      expect(submittedAnswers[1]['selectedOptionIds'], equals(['opt_1']));

      // Verify submission result stored
      expect(provider.lastSubmissionResult, isNotNull);
      expect(provider.lastSubmissionResult!['score_percent'], equals(100));
      expect(provider.lastSubmissionResult!['is_passed'], isTrue);
      expect(provider.lastSubmissionResult!['submission_id'], equals('sub_record_999'));
    });

    test('restartQuiz clears state and resets countdown timer', () async {
      final provider = QuizProvider();
      await provider.fetchQuestions('course_flutter_1');

      provider.selectedAnswer = 'FutureProvider';
      await provider.goToNextQuestion();

      provider.restartQuiz();

      expect(provider.currentQuestionIndex, equals(0));
      expect(provider.selectedAnswer, isEmpty);
      expect(provider.userAnswers, isEmpty);
      expect(provider.isQuizCompleted, isFalse);
      expect(provider.lastSubmissionResult, isNull);
      expect(provider.time, equals(20));
    });
  });
}
