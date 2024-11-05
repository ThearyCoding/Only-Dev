import 'package:e_leaningapp/core/global_navigation.dart';
import 'package:e_leaningapp/providers/quiz_provider.dart';
import 'package:e_leaningapp/screens/quiz-screen/review_question_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';
import '../../utils/show_dialog_infor_utils.dart';

class ResultQuizScreen extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final List<String> userAnswers;
  final List<String> correctAnswers;

  const ResultQuizScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.correctAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.read<QuizProvider>();
    int correctCount = 0;
    for (int i = 0; i < userAnswers.length; i++) {
      if (userAnswers[i] == correctAnswers[i]) {
        correctCount++;
      }
    }
    double correctPercentage = (correctCount / questions.length) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Test 2'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Practice Test 2 - Results',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${questions.length} questions | 40 minutes | 70% required to pass',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildPieChart(correctPercentage),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Attempt 1: ${correctPercentage >= 70 ? 'Passed!' : 'Failed!'}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: correctPercentage >= 70
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              Text(
                                '(70% required to pass)',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$correctPercentage% correct ($correctCount/${questions.length})',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '7 minutes',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'August 22, 2024 at 03:22 PM',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildLegend(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
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
              child: const Text('Review questions'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () async {
                bool? isExit = await askComfirmation(
                  context,
                  quizProvider.reTakeTest,
                  'Re-Quiz?',
                  'Are you sure you want to re-quiz?',
                );
                if (isExit == true) {
                  // ignore: use_build_context_synchronously
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
              child: const Text('Retake test'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(double correctPercentage) {
    return SizedBox(
      height: 100,
      width: 100,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.green,
              value: correctPercentage,
              title: '',
              radius: 10,
            ),
            PieChartSectionData(
              color: Colors.red,
              value: 100 - correctPercentage,
              title: '',
              radius: 10,
            ),
            PieChartSectionData(
              color: Colors.grey,
              value: 0,
              title: '',
              radius: 10,
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 30,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegendItem(Colors.green, 'Correct'),
        const SizedBox(height: 8),
        _buildLegendItem(Colors.red, 'Wrong'),
        const SizedBox(height: 8),
        _buildLegendItem(Colors.grey, 'Skipped/Unanswered'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    final context = navigatorKey.currentState!.context;
    if (context != null) {
      final isdark = Theme.of(context).brightness == Brightness.dark;
      return Row(
        children: [
          Container(
            width: 16,
            height: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
                fontSize: 16, color: isdark ? Colors.white : Colors.black),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
