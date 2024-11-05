import 'dart:developer';

import 'package:e_leaningapp/core/global_navigation.dart';
import 'package:e_leaningapp/di/dependency_injection.dart';
import 'package:e_leaningapp/export/export.dart';
import 'package:go_router/go_router.dart';

class QuizProvider with ChangeNotifier {
  List<Map<String, dynamic>> _questions = [];
  final User? _user = locator<FirebaseAuth>().currentUser;
  final FirebaseFirestore _firestore = locator<FirebaseFirestore>();
  int _currentQuestionIndex = 0;
  String _selectedAnswer = '';
  List<String> _userAnswers = [];
  int _timer = 20;
  Timer? _countdownTimer;

  late String _courseId;
  late String _categoryId;
  late String _title;
  late String defaultQuizId;
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
    notifyListeners(); // Notifies listeners of changes
  }

  void restartQuiz() {
    _countdownTimer?.cancel(); // Cancel any existing timer
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
    try {
      await _firestore
          .collection('user_progress_quiz')
          .doc(_user!.uid)
          .collection('quizzes')
          .doc(_courseId)
          .delete();
      restartQuiz();
      fetchQuestions(courseId);
    } catch (e) {
      log("Error resetting quiz: $e");
    }
  }

  Future<void> fetchQuestions(String courseId) async {
    _isFetching = true;
    notifyListeners();

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('quizzes')
          .doc(courseId)
          .collection('questions')
          .get();

      List<Map<String, dynamic>> fetchedQuestions =
          querySnapshot.docs.map((doc) => doc.data()).toList();

      for (var question in fetchedQuestions) {
        if (question['options'] != null && question['options'] is List) {
          List<dynamic> options = question['options'];
          options.shuffle();
        }
      }

      _questions = fetchedQuestions;
      notifyListeners();
      loadUserProgress();
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
      final context = navigatorKey.currentState!.context;

      if (context != null) {
        context.go(RoutesPath.resultquizscreen, extra: {
          "questions": _questions,
          "userAnswers": _userAnswers,
          "correctAnswers": _questions
              .map((question) => question["answer"] != null
                  ? question['answer'] as String
                  : '')
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
    if (_user!.uid.isEmpty) {
      log("Error saving user progress: userId is not set.");
      return;
    }

    try {
      await _firestore
          .collection('user_progress_quiz')
          .doc(_user.uid)
          .collection('quizzes')
          .doc(_courseId)
          .set({
        'currentQuestionIndex': _currentQuestionIndex,
        'userAnswers': _userAnswers,
        'isQuizCompleted': _isQuizCompleted,
        'timer': _timer,
      });
    } catch (e) {
      log("Error saving user progress: $e");
    }
  }

  Future<void> loadUserProgress() async {
    if (_user!.uid.isEmpty) {
      log("Error loading user progress: userId is not set.");
      return;
    }

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('user_progress_quiz')
          .doc(_user.uid)
          .collection('quizzes')
          .doc(_courseId)
          .get();

      if (snapshot.exists) {
        var data = snapshot.data();
        if (data != null) {
          _currentQuestionIndex = data['currentQuestionIndex'] ?? 0;
          _userAnswers = List<String>.from(data['userAnswers'] ?? []);
          _isQuizCompleted = data['isQuizCompleted'] ?? false;
          _timer = data['timer'] ?? 20;

          if (_isQuizCompleted) {
            final context = navigatorKey.currentState!.context;

            if (context != null) {
              // ignore: use_build_context_synchronously
              context.go(RoutesPath.resultquizscreen, extra: {
                "questions": _questions,
                "userAnswers": _userAnswers,
                "correctAnswers": _questions
                    .map((question) => question["answer"] != null
                        ? question['answer'] as String
                        : '')
                    .toList(),
              });
            }
          } else {
            startTimer();
          }
        }
      }
    } catch (e) {
      log("Error loading user progress: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    cancelTimer();
  }
}
