import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import '../../routes/app_routes.dart';

class QuizTabWidget extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final courseProvider = ref.watch(lectureNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: courseProvider.loadingQuestions
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : courseProvider.totalQuestions == 0
              ? const Center(
                  child: Text('No Questions'),
                )
              : Column(
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
                ),
              ],
            ),
    );
  }
}
