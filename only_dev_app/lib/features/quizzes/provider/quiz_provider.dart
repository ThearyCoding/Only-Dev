import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:only_dev_app/core/global_navigation.dart';
import 'package:only_dev_app/data/repositories/quiz_repository.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:only_dev_app/routes/app_routes.dart';

class QuizProvider with ChangeNotifier {
  final QuizRepository _quizRepository = locator<QuizRepository>();
  final SharedPreferences _prefs = locator<SharedPreferences>();
  List<Map<String, dynamic>> _questions = [];
  final User? _user = locator<FirebaseAuth>().currentUser;
  int _currentQuestionIndex = 0;
  String _selectedAnswer = '';
  List<String> _userAnswers = [];
  int _timer = 20;
  Timer? _countdownTimer;

  late String _courseId;
  late String _categoryId;
  late String _title;
  String defaultQuizId = '';
  bool _isQuizCompleted = false;
  bool _isFetching = false;

  // Getters
  List<Map<String, dynamic>> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  String get selectedAnswer => _selectedAnswer;
  List<String> get userAnswers => _userAnswers;
  int get time => _timer;
  bool get isQuizCompleted => _isQuizCompleted;
  bool get isFetching => _isFetching;
  String get courseId => _courseId;
  String get categoryId => _categoryId;
  String get title => _title;

  // Setters
  set setcourseId(String id) => _courseId = id;
  set setcategoryId(String id) => _categoryId = id;
  set settitle(String title) => _title = title;
  set selectedAnswer(String answer) {
    _selectedAnswer = answer;
    notifyListeners();
  }

  void restartQuiz() {
    _countdownTimer?.cancel();
    _currentQuestionIndex = 0;
    _selectedAnswer = '';
    _userAnswers.clear();
    _timer = 20;
    _isQuizCompleted = false;
    questions.clear();
    notifyListeners();

    startTimer();
    saveUserProgress();
  }

  Future<void> reTakeTest() async {
    final uid = _user?.uid ?? '';
    if (uid.isNotEmpty) {
      await _prefs.remove('quiz_progress_${uid}_$_courseId');
    }
    restartQuiz();
    fetchQuestions(_courseId);
  }

  Future<void> fetchQuestions(String courseId) async {
    _isFetching = true;
    notifyListeners();

    try {
      final quizzes = await _quizRepository.getQuizzesByCourse(courseId);
      List<Map<String, dynamic>> fetchedQuestions = [];
      if (quizzes.isNotEmpty) {
        final quiz = quizzes.first;
        defaultQuizId = (quiz['id'] ?? quiz['_id'] ?? '').toString();
        final raw = quiz['questions'] as List? ?? [];
        fetchedQuestions = raw.map((item) {
          final m = Map<String, dynamic>.from(item as Map);
          if (m['options'] != null && m['options'] is List) {
            final opts = (m['options'] as List).map((o) {
              if (o is Map) {
                return (o['text'] ?? o['title'] ?? '').toString();
              }
              return o.toString();
            }).toList();
            m['options'] = opts;
          }
          return m;
        }).toList();
      }

      for (var question in fetchedQuestions) {
        if (question['options'] != null && question['options'] is List) {
          List<dynamic> options = question['options'];
          options.shuffle();
        }
      }

      _questions = fetchedQuestions;
      notifyListeners();
      await loadUserProgress();
    } catch (e) {
      log("Error fetching questions: $e");
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  void startTimer() {
    if (_countdownTimer != null && _countdownTimer!.isActive) {
      _countdownTimer!.cancel();
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timer == 0) {
        goToNextQuestion();
        timer.cancel();
      } else {
        _timer--;
        log("Timer tick: $_timer seconds remaining.");
        notifyListeners();
      }
    });
  }

  void resetTimer() {
    _timer = 20;
    notifyListeners();
  }

  void cancelTimer() {
    if (_countdownTimer != null && _countdownTimer!.isActive) {
      log("Cancelling the active timer.");
      _countdownTimer!.cancel();
    }
  }

  void goToNextQuestion() {
    cancelTimer();

    if (_currentQuestionIndex < _questions.length - 1) {
      if (_currentQuestionIndex < _userAnswers.length) {
        _userAnswers[_currentQuestionIndex] = _selectedAnswer;
      } else {
        _userAnswers.add(_selectedAnswer);
      }
      saveUserProgress();

      _currentQuestionIndex++;
      _selectedAnswer = '';

      resetTimer();
      startTimer();
    } else {
      if (_currentQuestionIndex < _userAnswers.length) {
        _userAnswers[_currentQuestionIndex] = _selectedAnswer;
      } else {
        _userAnswers.add(_selectedAnswer);
      }
      _isQuizCompleted = true;
      saveUserProgress();
      final context = navigatorKey.currentState?.context;

      if (context != null && context.mounted) {
        context.go(RoutesPath.resultquizscreen, extra: {
          "questions": _questions,
          "userAnswers": _userAnswers,
          "correctAnswers": _questions
              .map((question) => (question["answer"] ?? '').toString())
              .toList(),
        });
      }
    }
    notifyListeners();
  }

  void goToPreviousQuestion() {
    cancelTimer();

    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      _selectedAnswer = _userAnswers[_currentQuestionIndex];

      resetTimer();
      startTimer();
    }
    notifyListeners();
  }

  Future<void> saveUserProgress() async {
    final uid = _user?.uid ?? '';
    if (uid.isEmpty) return;

    try {
      final data = {
        'currentQuestionIndex': _currentQuestionIndex,
        'userAnswers': _userAnswers,
        'isQuizCompleted': _isQuizCompleted,
        'timer': _timer,
      };
      await _prefs.setString('quiz_progress_${uid}_$_courseId', jsonEncode(data));
    } catch (e) {
      log("Error saving user progress: $e");
    }
  }

  Future<void> loadUserProgress() async {
    final uid = _user?.uid ?? '';
    if (uid.isEmpty) return;

    try {
      final raw = _prefs.getString('quiz_progress_${uid}_$_courseId');
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        _currentQuestionIndex = data['currentQuestionIndex'] ?? 0;
        _userAnswers = List<String>.from(data['userAnswers'] ?? []);
        _isQuizCompleted = data['isQuizCompleted'] ?? false;
        _timer = data['timer'] ?? 20;

        if (_isQuizCompleted) {
          final context = navigatorKey.currentState?.context;

          if (context != null && context.mounted) {
            context.go(RoutesPath.resultquizscreen, extra: {
              "questions": _questions,
              "userAnswers": _userAnswers,
              "correctAnswers": _questions
                  .map((question) => (question["answer"] ?? '').toString())
                  .toList(),
            });
          }
        } else {
          startTimer();
        }
      }
    } catch (e) {
      log("Error loading user progress: $e");
    }
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }
}
