import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/routes/app_routes.dart';

class CourseQuizTabWidget extends ConsumerWidget {
  final CourseContentParams params;
  final String title;

  const CourseQuizTabWidget({
    super.key,
    required this.params,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(courseContentNotifierProvider(params));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.loadingQuestions) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.totalQuestions == 0) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 48,
              color: isDark ? Colors.white38 : Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No questions available for this course.',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              "Let's Quiz",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            context,
            isDark,
            [
              _buildInfoRow('Total Questions', '${state.totalQuestions} Questions'),
              const Divider(height: 24),
              _buildInfoRow('Time Limit', '20s per question'),
              const Divider(height: 24),
              _buildInfoRow('Total Score', '20 Points'),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              if (params.categoryId.isNotEmpty &&
                  params.courseId.isNotEmpty &&
                  title.isNotEmpty) {
                context.push(
                  RoutesPath.quizscreen,
                  extra: {
                    "categoryId": params.categoryId,
                    "title": title,
                    "courseId": params.courseId,
                  },
                );
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Start Quiz',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    bool isDark,
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
