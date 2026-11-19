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
  User? get _user {
    try {
      if (locator.isRegistered<FirebaseAuth>()) {
        return locator<FirebaseAuth>().currentUser;
      }
    } catch (_) {}
    return null;
  }

  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  String _selectedAnswer = '';
  List<String> _userAnswers = [];
  int _timer = 20;
  int _elapsedSeconds = 0;
  Timer? _countdownTimer;

  String _courseId = '';
  String _categoryId = '';
  String _title = '';
  String defaultQuizId = '';
  int _passingScorePercent = 70;
  int _timeLimitMinutes = 0;
  int _maxAttemptsAllowed = 0;

  bool _isQuizCompleted = false;
  bool _isFetching = false;
  bool _isSubmitting = false;
  Map<String, dynamic>? _lastSubmissionResult;

  // Getters
  List<Map<String, dynamic>> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  String get selectedAnswer => _selectedAnswer;
  List<String> get userAnswers => _userAnswers;
  int get time => _timer;
  int get elapsedSeconds => _elapsedSeconds;
  bool get isQuizCompleted => _isQuizCompleted;
  bool get isFetching => _isFetching;
  bool get isSubmitting => _isSubmitting;
  Map<String, dynamic>? get lastSubmissionResult => _lastSubmissionResult;
  String get courseId => _courseId;
  String get categoryId => _categoryId;
  String get title => _title;
  int get passingScorePercent => _passingScorePercent;
  int get timeLimitMinutes => _timeLimitMinutes;
  int get maxAttemptsAllowed => _maxAttemptsAllowed;

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
    _elapsedSeconds = 0;
    _isQuizCompleted = false;
    _isSubmitting = false;
    _lastSubmissionResult = null;
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
    await fetchQuestions(_courseId);
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
        _passingScorePercent = (quiz['passing_score_percent'] ?? quiz['passingScorePercent'] ?? 70) as int;
        _timeLimitMinutes = (quiz['time_limit_minutes'] ?? quiz['timeLimitMinutes'] ?? 0) as int;
        _maxAttemptsAllowed = (quiz['max_attempts_allowed'] ?? quiz['maxAttemptsAllowed'] ?? 0) as int;

        if (_title.isEmpty && quiz['title'] != null) {
          _title = quiz['title'].toString();
        }

        final raw = quiz['questions'] as List? ?? [];
        fetchedQuestions = raw.map((item) {
          final m = Map<String, dynamic>.from(item as Map);
          final prompt = (m['prompt'] ?? m['question'] ?? '').toString();
          m['prompt'] = prompt;
          m['question'] = prompt;
          m['id'] = (m['_id'] ?? m['id'] ?? '').toString();
          m['_id'] = m['id'];

          final rawOptsList = m['options'] as List? ?? [];
          final List<Map<String, dynamic>> rawOptions = [];
          final List<String> optTexts = [];
          String correctAnswerText = '';
          String explanationText = '';

          for (final opt in rawOptsList) {
            if (opt is Map) {
              final optMap = Map<String, dynamic>.from(opt);
              final id = (optMap['id'] ?? '').toString();
              final text = (optMap['text'] ?? optMap['title'] ?? '').toString();
              final isCorrect = optMap['is_correct'] == true || optMap['isCorrect'] == true;
              final expl = (optMap['explanation'] ?? '').toString();

              if (isCorrect) {
                correctAnswerText = text;
                explanationText = expl;
              }

              rawOptions.add({
                'id': id,
                'text': text,
                'is_correct': isCorrect,
                'explanation': expl,
              });
              optTexts.add(text);
            } else {
              final text = opt.toString();
              rawOptions.add({
                'id': text,
                'text': text,
                'is_correct': false,
                'explanation': '',
              });
              optTexts.add(text);
            }
          }

          if (correctAnswerText.isEmpty && m['answer'] != null) {
            correctAnswerText = m['answer'].toString();
          }
          if (explanationText.isEmpty && m['explanation'] != null) {
            explanationText = m['explanation'].toString();
          }

          m['options'] = optTexts;
          m['rawOptions'] = rawOptions;
          m['answer'] = correctAnswerText;
          m['explanation'] = explanationText;

          return m;
        }).toList();
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
      _elapsedSeconds++;
      if (_timer == 0) {
        goToNextQuestion();
        timer.cancel();
      } else {
        _timer--;
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
      _countdownTimer!.cancel();
    }
  }

  Future<void> goToNextQuestion() async {
    cancelTimer();

    // Record the user's selection for the current question
    if (_currentQuestionIndex < _userAnswers.length) {
      _userAnswers[_currentQuestionIndex] = _selectedAnswer;
    } else {
      _userAnswers.add(_selectedAnswer);
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      await saveUserProgress();

      _currentQuestionIndex++;
      _selectedAnswer = (_currentQuestionIndex < _userAnswers.length)
          ? _userAnswers[_currentQuestionIndex]
          : '';

      resetTimer();
      startTimer();
      notifyListeners();
    } else {
      // Completed all questions -> Submit attempt to backend
      _isQuizCompleted = true;
      _isSubmitting = true;
      notifyListeners();

      Map<String, dynamic>? submissionResult;

      if (defaultQuizId.isNotEmpty) {
        try {
          final timeTaken = _elapsedSeconds > 0
              ? _elapsedSeconds
              : (_questions.length * 20 - _timer);

          final submissionPayload = {
            'timeTakenSeconds': timeTaken,
            'answers': List.generate(_questions.length, (i) {
              final q = _questions[i];
              final qId = (q['_id'] ?? q['id'] ?? '').toString();
              final userAns = i < _userAnswers.length ? _userAnswers[i] : '';
              final rawOpts = (q['rawOptions'] as List<dynamic>?) ?? [];

              String selectedOptId = '';
              for (final opt in rawOpts) {
                if (opt is Map &&
                    (opt['text'] == userAns || opt['id'] == userAns)) {
                  selectedOptId = (opt['id'] ?? '').toString();
                  break;
                }
              }

              return {
                'questionId': qId,
                'selectedOptionIds': selectedOptId.isNotEmpty ? [selectedOptId] : <String>[],
              };
            }),
          };

          submissionResult = await _quizRepository.submitQuiz(defaultQuizId, submissionPayload);
          _lastSubmissionResult = submissionResult;
          log("Quiz attempt successfully submitted: ${submissionResult['submission_id'] ?? submissionResult['submissionId']}");
        } catch (e) {
          log("Error submitting quiz attempt to backend: $e");
        }
      }

      _isSubmitting = false;
      await saveUserProgress();
      notifyListeners();

      final context = navigatorKey.currentState?.context;
      if (context != null && context.mounted) {
        context.go(RoutesPath.resultquizscreen, extra: {
          "questions": _questions,
          "userAnswers": _userAnswers,
          "correctAnswers": _questions
              .map((question) => (question["answer"] ?? '').toString())
              .toList(),
          "submission": submissionResult,
        });
      }
    }
  }

  void goToPreviousQuestion() {
    cancelTimer();

    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      _selectedAnswer = (_currentQuestionIndex < _userAnswers.length)
          ? _userAnswers[_currentQuestionIndex]
          : '';

      resetTimer();
      startTimer();
      notifyListeners();
    }
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
        'elapsedSeconds': _elapsedSeconds,
        'lastSubmissionResult': _lastSubmissionResult,
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
        _elapsedSeconds = data['elapsedSeconds'] ?? 0;
        if (data['lastSubmissionResult'] != null) {
          _lastSubmissionResult = Map<String, dynamic>.from(data['lastSubmissionResult'] as Map);
        }

        if (_isQuizCompleted) {
          final context = navigatorKey.currentState?.context;
          if (context != null && context.mounted) {
            context.go(RoutesPath.resultquizscreen, extra: {
              "questions": _questions,
              "userAnswers": _userAnswers,
              "correctAnswers": _questions
                  .map((question) => (question["answer"] ?? '').toString())
                  .toList(),
              "submission": _lastSubmissionResult,
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
