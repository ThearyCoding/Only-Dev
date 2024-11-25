import '../../export/export.dart';
import '../../providers/lecture_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class QuizTabWidget extends StatelessWidget {
  final String categoryId;
  final String courseId;
  final String title;

  const QuizTabWidget({
    super.key,
    required this.categoryId,
    required this.courseId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const PageStorageKey<String>('tab-quiz'),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Consumer<LectureProvider>(
        builder: (context, courseProvider, child) {
          if (courseProvider.loadingquestion) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (courseProvider.totalQuestions == 0) {
            return const Center(
              child: Text('No Questions'),
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Let's Quiz",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Question',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${courseProvider.totalQuestions} Questions',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Time Quiz',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '1 question is 20s',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Score',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '20',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (categoryId.isNotEmpty &&
                            courseId.isNotEmpty &&
                            title.isNotEmpty) {
                          context.push(
                            RoutesPath.quizscreen,
                            extra: {
                              "categoryId": categoryId,
                              "title": title,
                              "courseId": courseId,
                            },
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Start Quiz',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                )
              ],
            );
          }
        },
      ),
    );
  }
}
