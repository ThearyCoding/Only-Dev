import 'package:e_leaningapp/export/export.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CourseCardRegistered extends StatefulWidget {
  final AdminModel admin;
  final CourseModel course;
  final int currentLessons;
  final int totalLessons;

  const CourseCardRegistered({
    super.key,
    required this.admin,
    required this.course,
    required this.currentLessons,
    required this.totalLessons,
  });

  @override
  CourseCardRegisteredState createState() => CourseCardRegisteredState();
}

class CourseCardRegisteredState extends State<CourseCardRegistered> {
  double getProgress() {
    return widget.totalLessons == 0
        ? 0.0
        : widget.currentLessons / widget.totalLessons;
  }


 @override
Widget build(BuildContext context) {
  double progress = getProgress();
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final cardColor = isDarkMode ? Colors.grey.withOpacity(.1) : Colors.white;
  final textColor = isDarkMode ? Colors.white : Colors.black;
  final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black87;
  const borderColor = Colors.transparent;

  return ZoomTapAnimation(
    onTap: () {
      context.push(RoutesPath.topicScreen, extra: {
        'categoryId': widget.course.categoryId,
        'courseId': widget.course.id,
        'title': widget.course.title,
      });
    },
    child: Card(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: borderColor, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            child: CachedNetworkImage(
              imageUrl: widget.course.imageUrl,
              height: 180.0,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[700]!
                    : Colors.grey[300]!,
                highlightColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[500]!
                    : Colors.grey[100]!,
                child: Container(
                  height: 180.0,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A Course by ${widget.admin.name}',
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      fontSize: 14.0,
                      color: textColor,
                    ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8.0),
                Text(
                  widget.course.title,
                  style: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.course.description ?? '',
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: secondaryTextColor, fontSize: 12),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Text(
                      '${widget.currentLessons} / ${widget.totalLessons} lessons',
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      progress == 1.0 ? 'Completed' : '${(progress * 100).toInt()}%',
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                if (progress < 1.0)
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    minHeight: 8.0,
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

}
