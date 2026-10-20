import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:numeral/numeral.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/utils/time_utils.dart';
import 'package:only_dev_app/widgets/topic-widget/description_topic_widget.dart';

class CourseDescriptionSheet extends ConsumerWidget {
  final CourseContentParams params;
  final VoidCallback onClose;

  const CourseDescriptionSheet({
    super.key,
    required this.params,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(courseContentNotifierProvider(params));
    final lecture = state.currentLecture;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (lecture == null) {
      return const SizedBox.shrink();
    }

    final formattedViews = lecture.views.numeral(digits: 1);
    final formattedDate = TimeUtils.formatTimestamp(lecture.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: SvgPicture.asset(
                    'assets/icons/icons8-cancel.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      isDark ? Colors.white : Colors.black87,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lecture.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '$formattedViews Views',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DescriptionWidget(
                    videoDescription: lecture.description.isNotEmpty
                        ? lecture.description
                        : 'No description available for this lecture.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
