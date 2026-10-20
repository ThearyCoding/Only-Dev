import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:numeral/numeral.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/utils/time_utils.dart';

class CourseVideoHeaderWidget extends ConsumerWidget {
  final CourseContentParams params;
  final VoidCallback onMoreTap;

  const CourseVideoHeaderWidget({
    super.key,
    required this.params,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(courseContentNotifierProvider(params));
    final lecture = state.currentLecture;

    if (lecture == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white60 : Colors.black54;

    final formattedViews = lecture.views.numeral(digits: 1);
    final formattedDate = TimeUtils.formatTimestamp(lecture.createdAt);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lecture.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '$formattedViews Views',
                style: TextStyle(fontSize: 12, color: secondaryTextColor),
              ),
              const SizedBox(width: 12),
              Text(
                '•  $formattedDate',
                style: TextStyle(fontSize: 12, color: secondaryTextColor),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onMoreTap,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    '...more',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
