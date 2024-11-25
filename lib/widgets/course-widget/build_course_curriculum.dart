import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import '../../providers/lecture_provider.dart';
import '../../utils/time_utils.dart';

class BuildCourseCurriculum extends StatelessWidget {
  final LectureProvider lectureProvider;
  const BuildCourseCurriculum({super.key, required this.lectureProvider});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Curriculum',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 5),
          ListView.builder(
            shrinkWrap: true,
            itemCount: lectureProvider.sections.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (ctx, index) {
              final section = lectureProvider.sections[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ExpandablePanel(
                  theme: ExpandableThemeData(
                    hasIcon: true,
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    tapBodyToCollapse: false,
                    tapHeaderToExpand: false,
                    inkWellBorderRadius: BorderRadius.circular(10),
                    iconColor: isDarkMode ? Colors.white : Colors.black,
                  ),
                  header: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Section ${index + 1}: ${section.title}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  collapsed: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      // ignore: avoid_types_as_parameter_names
                      '${section.lectures.length} lectures | ${TimeUtils.formatDuration(section.lectures.fold<int>(0, (sum, lecture) => sum + lecture.videoDuration))}',
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  expanded: ListView.separated(
                    padding: EdgeInsets.zero,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey,
                    ),
                    itemCount: section.lectures.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10),
                        child: Text(
                          section.lectures[index].title,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
