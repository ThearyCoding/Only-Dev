import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:only_dev_app/core/app_style.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/features/quizzes/view/review_question_screen.dart';
import 'package:only_dev_app/routes/app_routes.dart';
import 'package:only_dev_app/utils/show_dialog_infor_utils.dart';

class ResultQuizScreen extends ConsumerWidget {
  final List<Map<String, dynamic>> questions;
  final List<String> userAnswers;
  final List<String> correctAnswers;
  final Map<String, dynamic>? submission;

  const ResultQuizScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.correctAnswers,
    this.submission,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizProvider = ref.watch(quizNotifierProvider);
    final totalQuestions = questions.length;

    // Calculate fallback local score if submission is null
    int localCorrectCount = 0;
    for (int i = 0; i < userAnswers.length; i++) {
      if (i < correctAnswers.length &&
          userAnswers[i].isNotEmpty &&
          userAnswers[i].trim().toLowerCase() ==
              correctAnswers[i].trim().toLowerCase()) {
        localCorrectCount++;
      }
    }
    final double localPercentage =
        totalQuestions > 0 ? (localCorrectCount / totalQuestions) * 100 : 0.0;

    // Use backend-evaluated metrics when available
    final double scorePercent = (submission?['score_percent'] ??
            submission?['scorePercent'] as num?)
        ?.toDouble() ??
        localPercentage;
    final int passingScore = (submission?['passing_score_percent'] ??
            submission?['passingScorePercent'] ??
            quizProvider.passingScorePercent) as int;
    final bool isPassed = submission?['is_passed'] ??
        submission?['isPassed'] ??
        (scorePercent >= passingScore);
    final int attemptNumber = (submission?['attempt_number'] ??
        submission?['attemptNumber'] ??
        1) as int;
    final int timeTaken = (submission?['time_taken_seconds'] ??
        submission?['timeTakenSeconds'] ??
        quizProvider.elapsedSeconds) as int;

    // Determine correct count from answers if available
    int correctCount = localCorrectCount;
    final answersList = submission?['answers'] as List?;
    if (answersList != null && answersList.isNotEmpty) {
      correctCount = answersList
          .where((a) => a is Map && (a['is_correct'] == true || a['isCorrect'] == true))
          .length;
    }

    final quizTitle = quizProvider.title.isNotEmpty
        ? quizProvider.title
        : 'Quiz Results';

    final String formattedDate = DateFormat('MMMM d, yyyy · hh:mm a').format(DateTime.now());
    final String formattedDuration = timeTaken >= 60
        ? '${timeTaken ~/ 60}m ${timeTaken % 60}s'
        : '${timeTaken}s';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              quizTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$totalQuestions questions | $passingScore% required to pass',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildPieChart(scorePercent),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isPassed
                                      ? AppStyle.primaryColor.withOpacity(0.12)
                                      : AppStyle.error.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Attempt $attemptNumber: ${isPassed ? 'Passed!' : 'Failed!'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isPassed
                                        ? AppStyle.primaryColor
                                        : AppStyle.error,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${scorePercent.toStringAsFixed(0)}% correct',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$correctCount of $totalQuestions questions',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.timer_outlined,
                                      size: 15, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedDuration,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _buildLegend(context),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewQuestionScreen(
                      questions: questions,
                      userAnswers: userAnswers,
                      correctAnswers: correctAnswers,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('Review Questions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyle.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                bool? isExit = await askComfirmation(
                  context,
                  quizProvider.reTakeTest,
                  'Retake Quiz',
                  'Are you sure you want to retake this quiz?',
                );
                if (isExit == true && context.mounted) {
                  context.go(
                    RoutesPath.quizscreen,
                    extra: {
                      "categoryId": quizProvider.categoryId,
                      "title": quizProvider.title,
                      "courseId": quizProvider.courseId,
                    },
                  );
                }
              },
              icon: const Icon(Icons.replay_outlined),
              label: const Text('Retake Quiz'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppStyle.primaryColor,
                side: const BorderSide(color: AppStyle.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                context.go(
                  RoutesPath.topicScreen,
                  extra: {
                    "categoryId": quizProvider.categoryId,
                    "title": quizProvider.title,
                    "courseId": quizProvider.courseId,
                  },
                );
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Course Curriculum'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(double correctPercentage) {
    final double clampedCorrect = correctPercentage.clamp(0.0, 100.0);
    final double clampedWrong = 100.0 - clampedCorrect;

    return SizedBox(
      height: 100,
      width: 100,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: AppStyle.primaryColor,
              value: clampedCorrect > 0 ? clampedCorrect : 0.001,
              title: '',
              radius: 12,
            ),
            PieChartSectionData(
              color: AppStyle.error,
              value: clampedWrong > 0 ? clampedWrong : 0.001,
              title: '',
              radius: 12,
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 32,
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(AppStyle.primaryColor, 'Correct'),
        _buildLegendItem(AppStyle.error, 'Wrong'),
        _buildLegendItem(Colors.grey.shade400, 'Passing Bar (70%)'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}
