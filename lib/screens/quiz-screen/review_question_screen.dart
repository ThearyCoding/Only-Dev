import 'package:e_leaningapp/widgets/cards/build_review_question_card.dart';
import 'package:flutter/material.dart';

class ReviewQuestionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final List<String> userAnswers;
  final List<String> correctAnswers;

  const ReviewQuestionScreen({
    Key? key,
    required this.questions,
    required this.userAnswers,
    required this.correctAnswers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Questions'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final questionData = questions[index];
          final String question = questionData['question'] as String;
          final List<String> options =
              List<String>.from(questionData['options'] as List);
          final String correctAnswerText =
              (questionData['answer'] as String?)?.trim().toLowerCase() ?? '';
          final String userAnswer = userAnswers[index].trim().toLowerCase();

          // Handle null cases and find the indexes safely
          final int correctAnswerIndex = options.indexWhere(
              (option) => option.trim().toLowerCase() == correctAnswerText);
          final int selectedAnswerIndex = options.indexWhere(
              (option) => option.trim().toLowerCase() == userAnswer);

          final bool isCorrect = correctAnswerIndex == selectedAnswerIndex;
          final String explanation =
              questionData['explanation'] as String? ?? '';

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
