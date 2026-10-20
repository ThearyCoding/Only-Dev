import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/model/lecture_model.dart';
import 'package:only_dev_app/model/section_model.dart';
import 'package:only_dev_app/utils/time_utils.dart';

class CourseCurriculumTabWidget extends ConsumerWidget {
  final CourseContentParams params;

  const CourseCurriculumTabWidget({
    super.key,
    required this.params,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(courseContentNotifierProvider(params));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 48,
              color: isDark ? Colors.white38 : Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No sections or lessons available.',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: state.sections.length,
      itemBuilder: (context, sectionIndex) {
        final section = state.sections[sectionIndex];
        final isCurrentSection = state.selectedSectionIndex == sectionIndex;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isCurrentSection
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                  : (isDark ? Colors.white10 : Colors.grey.shade200),
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: isCurrentSection || sectionIndex == 0,
              title: Text(
                section.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Text(
                '${section.lectures.length} lessons',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
              ),
              children: section.lectures.map((lecture) {
                return _buildLectureTile(context, ref, section, lecture, state, isDark);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLectureTile(
    BuildContext context,
    WidgetRef ref,
    Section section,
    Lecture lecture,
    CourseContentState state,
    bool isDark,
  ) {
    final isSelected = state.selectedLectureId == lecture.id;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? primaryColor.withValues(alpha: 0.12)
            : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 3.5,
          ),
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          isSelected
              ? Icons.play_circle_fill
              : (lecture.videoUrl.isNotEmpty
                  ? Icons.play_circle_outline
                  : Icons.article_outlined),
          color: isSelected
              ? primaryColor
              : (isDark ? Colors.white60 : Colors.black54),
          size: 22,
        ),
        title: Text(
          lecture.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? primaryColor
                : (isDark ? Colors.white : Colors.black87),
          ),
        ),
        subtitle: lecture.videoDuration > 0
            ? Text(
                TimeUtils.formatDuration(lecture.videoDuration),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
              )
            : null,
        onTap: () {
          ref
              .read(courseContentNotifierProvider(params).notifier)
              .playLecture(lecture, section);
        },
      ),
    );
  }
}
