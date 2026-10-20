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
    final primaryColor = Theme.of(context).primaryColor;
    final effectiveSections = sections ?? lectureProvider?.sections ?? [];

    if (effectiveSections.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalLectures = effectiveSections.fold<int>(
      0,
      (sum, sec) => sum + sec.lectures.length,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Curriculum',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Text(
                '${effectiveSections.length} sections • $totalLectures lectures',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white60 : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            itemCount: effectiveSections.length,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, index) {
              final section = effectiveSections[index];
              final rawTitle = section.title.trim();
              final sectionTitle = rawTitle.toLowerCase().startsWith('section')
                  ? rawTitle
                  : 'Section ${index + 1}: $rawTitle';

              final sectionDuration = section.lectures.fold<int>(
                0,
                (sum, l) => sum + l.videoDuration,
              );

              return Container(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.grey.shade200,
                  ),
                ),
                child: ExpandableNotifier(
                  initialExpanded: index == 0,
                  child: ExpandablePanel(
                    theme: ExpandableThemeData(
                      hasIcon: true,
                      headerAlignment: ExpandablePanelHeaderAlignment.center,
                      tapHeaderToExpand: true,
                      tapBodyToCollapse: false,
                      iconPadding: const EdgeInsets.only(right: 14),
                      iconColor: isDarkMode
                          ? Colors.white70
                          : const Color(0xFF64748B),
                    ),
                    header: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sectionTitle,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: isDarkMode
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${section.lectures.length} lectures${sectionDuration > 0 ? " • ${TimeUtils.formatDuration(sectionDuration)}" : ""}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode
                                        ? Colors.white54
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    collapsed: const SizedBox.shrink(),
                    expanded: section.lectures.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: 54, right: 14, bottom: 14),
                            child: Text(
                              'No lessons available yet in this section',
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color:
                                    isDarkMode ? Colors.white38 : Colors.grey,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 8),
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              thickness: 1,
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.grey.shade100,
                            ),
                            itemCount: section.lectures.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, lIdx) {
                              final lecture = section.lectures[lIdx];
                              final isPreview = lIdx == 0;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isPreview
                                            ? primaryColor
                                                .withValues(alpha: 0.12)
                                            : Colors.grey
                                                .withValues(alpha: 0.12),
                                      ),
                                      child: Icon(
                                        isPreview
                                            ? Icons.play_arrow_rounded
                                            : Icons.lock_outline_rounded,
                                        size: 14,
                                        color: isPreview
                                            ? primaryColor
                                            : (isDarkMode
                                                ? Colors.white38
                                                : Colors.grey),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        lecture.title,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: isDarkMode
                                              ? Colors.white.withValues(alpha: 0.87)
                                              : const Color(0xFF334155),
                                        ),
                                      ),
                                    ),
                                    if (isPreview)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        margin:
                                            const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: primaryColor
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Preview',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ),
                                    if (lecture.videoDuration > 0)
                                      Text(
                                        TimeUtils.formatDuration(
                                            lecture.videoDuration),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDarkMode
                                              ? Colors.white38
                                              : Colors.grey.shade500,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
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
