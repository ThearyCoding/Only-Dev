import 'package:cloud_firestore/cloud_firestore.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final String answer;
  final Timestamp timestamp;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
    required this.timestamp,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['question'],
      options: List<String>.from(map['options']),
      answer: map['answer'],
      timestamp: map['timestamp'],
    );
  }
}