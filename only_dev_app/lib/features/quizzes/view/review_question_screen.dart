import 'package:flutter/material.dart';
import 'package:only_dev_app/widgets/cards/build_review_question_card.dart';

class ReviewQuestionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final List<String> userAnswers;
  final List<String> correctAnswers;

  const ReviewQuestionScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.correctAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Questions'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final questionData = questions[index];
          final String question = (questionData['question'] ?? questionData['prompt'] ?? '').toString();
          final List<String> options = List<String>.from((questionData['options'] as List?) ?? []);
          final String correctAnswerText =
              (questionData['answer'] as String?)?.trim().toLowerCase() ?? '';
          final String userAnswer =
              (index < userAnswers.length ? userAnswers[index] : '').trim().toLowerCase();

          // Safely find matching indices
          final int correctAnswerIndex = options.indexWhere(
              (option) => option.trim().toLowerCase() == correctAnswerText);
          final int selectedAnswerIndex = options.indexWhere(
              (option) => option.trim().toLowerCase() == userAnswer);

          final bool isCorrect = correctAnswerIndex != -1 &&
              correctAnswerIndex == selectedAnswerIndex;
          final String explanation =
              (questionData['explanation'] ?? '').toString();

          return ReviewQuestionCard(
            question: question,
            options: options,
            correctAnswer: correctAnswerIndex,
            selectedAnswer: selectedAnswerIndex,
            isCorrect: isCorrect,
            explanation: explanation,
          );
        },
      ),
    );
  }
}
