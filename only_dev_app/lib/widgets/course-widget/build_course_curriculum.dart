import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:only_dev_app/features/courses/provider/lecture_provider.dart';
import 'package:only_dev_app/model/section_model.dart';
import '../../utils/time_utils.dart';

class BuildCourseCurriculum extends StatelessWidget {
  final LectureProvider? lectureProvider;
  final List<Section>? sections;

  const BuildCourseCurriculum({
    super.key,
    this.lectureProvider,
    this.sections,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final effectiveSections = sections ?? lectureProvider?.sections ?? [];

    if (effectiveSections.isEmpty) {
      return const SizedBox.shrink();
    }

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
            itemCount: effectiveSections.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (ctx, index) {
              final section = effectiveSections[index];
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
