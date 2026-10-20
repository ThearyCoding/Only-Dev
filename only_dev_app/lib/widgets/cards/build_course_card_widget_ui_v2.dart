import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../app_widgets/app_image_widget.dart';
import '../../routes/app_routes.dart';
import '../../widgets/other-widget/custom_dotted_border.dart';
import '../../generated/l10n.dart';
import '../../model/user_model.dart';
import '../../model/courses_model.dart';
import '../../utils/app_toast_utils.dart';
import '../../utils/time_utils.dart';
import '../background-widget/animation_colors_gradients.dart';

class CourseCardV2 extends StatelessWidget {
  final CourseModel course;
  final UserModel admin;
  final int quizCount;
  final bool isRegistered;
  final int totalLectures;

  const CourseCardV2({
    super.key,
    required this.course,
    required this.admin,
    required this.quizCount,
    required this.isRegistered,
    required this.totalLectures,
  });

  void _navigation(BuildContext context, AppLocalizations localization) {
    if (isRegistered) {
      context.push(
        RoutesPath.topicScreen,
        extra: {
          'courseId': course.id,
          'categoryId': course.categoryId,
          'title': course.title,
        },
      );
    } else if (course.status != "active" && course.status != "published") {
      AppToastUtils.warning(localization.Thiscoursewillbeavailableshortly);
    } else {
      context.push(
        RoutesPath.detailCourseScreen,
        extra: {
          'categoryId': course.categoryId,
          'courseId': course.id,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey.withValues(alpha: .1) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final localization = AppLocalizations.of(context);
    const buttonColor = Colors.green;

    return ZoomTapAnimation(
      onTap: () => _navigation(context, localization),
      child: Card(
        color: cardColor,
        elevation: isDarkMode ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: isDarkMode
              ? BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1.0)
              : BorderSide.none,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AppImageWidget(
                  imageUrl: course.imageUrl,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                  blurHash: course.blurHash,
                  fallbackIcon: Icons.menu_book_outlined,
                ),
                if (TimeUtils.isNew(course.createdAt, 4, TimeUnit.days))
                  Positioned(
                    left: 8,
                    top: 8,
                    child: SizedBox(
                      width: 80,
                      height: 30,
                      child: AnimatedGradientContainer(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: Text(
                              localization.NEW,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (course.price == 0 || course.price == null) &&
                              (course.status == "active" ||
                                  course.status == "published")
                          ? Colors.green
                          : (course.status == "active" ||
                                  course.status == "published")
                              ? Colors.green
                              : Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (course.status == "active" || course.status == "published")
                          ? ((course.price == 0 || course.price == null)
                              ? localization.Free
                              : '\$${course.price!.toStringAsFixed(2)}')
                          : localization.Comingsoon,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description ?? '',
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: secondaryTextColor, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.people, color: secondaryTextColor),
                      const SizedBox(width: 4),
                      Text(
                        course.registerCounts != null
                            ? '${course.registerCounts} ${localization.students}'
                            : '0 ${localization.students}',
                        style:
                            TextStyle(color: secondaryTextColor, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.video_library, color: secondaryTextColor),
                      const SizedBox(width: 4),
                      Text(
                        '$totalLectures ${localization.lectures}',
                        style:
                            TextStyle(color: secondaryTextColor, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      AppCircleAvatar(
                        imageUrl: admin.imageUrl,
                        name: admin.name,
                        radius: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        admin.name,
                        style: TextStyle(color: textColor, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomDottedButton(
                        label: isRegistered
                            ? localization.Continue
                            : localization.enrollnow,
                        icon: isRegistered
                            ? Icons.play_arrow
                            : Icons.arrow_forward_rounded,
                        color: buttonColor,
                        onPressed: () => _navigation(context, localization),
                      ),
                    ],
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
