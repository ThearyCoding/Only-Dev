import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../routes/app_routes.dart';
import '../../widgets/other-widget/custom_dotted_border.dart';
import '../../generated/l10n.dart';
import '../../model/admin_model.dart';
import '../../model/courses_model.dart';
import '../../utils/show_error_utils.dart';
import '../../utils/time_utils.dart';
import '../background-widget/animation_colors_gradients.dart';

class CourseCardV2 extends StatefulWidget {
  final CourseModel course;
  final AdminModel admin;
  final int quizCount;
  final bool isRegistered;
  final int totalLectures;

  const CourseCardV2({
    Key? key,
    required this.course,
    required this.admin,
    required this.quizCount,
    required this.isRegistered,
    required this.totalLectures,
  }) : super(key: key);

  @override
  CourseCardV2State createState() => CourseCardV2State();
}

class CourseCardV2State extends State<CourseCardV2>
    with TickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  bool _isTapped = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey.withOpacity(.1) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final borderColor = _isTapped ? Colors.green : Colors.transparent;
    final localization = AppLocalizations.of(context);

    return ZoomTapAnimation(
      onTap: (){
       
        navigation(localization);
        setState(() {
           _isTapped = true;
        });
      },
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderColor, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (widget.course.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(10)),
                    child: CachedNetworkImage(
                      imageUrl: widget.course.imageUrl,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]!
                                : Colors.grey[300]!,
                        highlightColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[600]!
                                : Colors.grey[100]!,
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                if (TimeUtils.isNew(
                    widget.course.timestamp, 4, TimeUnit.days))
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.course.price == 0 &&
                              widget.course.status == true
                          ? Colors.green
                          : widget.course.status == true
                              ? Colors.green
                              : Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.course.price == 0 && widget.course.status == true
                          ? localization.Free
                          : widget.course.status == true
                              ? '\$${widget.course.price!.toStringAsFixed(2)}'
                              : localization.Comingsoon,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16),
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
                    widget.course.title,
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.course.description ?? '',
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
                        widget.course.registerCounts != null
                            ? '${widget.course.registerCounts} ${localization.students}'
                            : '0 ${localization.students}',
                        style: TextStyle(
                            color: secondaryTextColor, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.video_library, color: secondaryTextColor),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.totalLectures} ${localization.lectures}',
                        style: TextStyle(
                            color: secondaryTextColor, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider(widget.admin.imageUrl),
                        radius: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.admin.name,
                        style: TextStyle(color: textColor, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomDottedButton(
                        label: widget.isRegistered
                            ? localization.Continue
                            : localization.enrollnow,
                        icon: widget.isRegistered
                            ? Icons.play_arrow
                            : Icons.arrow_forward_rounded,
                        color: borderColor,
                        onPressed: () => navigation(localization),
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

  navigation(AppLocalizations localization) {
    if (widget.isRegistered) {
      context.push(
        RoutesPath.topicScreen,
        extra: {
          'courseId': widget.course.id,
          'categoryId': widget.course.categoryId,
          'title': widget.course.title,
        },
      );
    } else if (widget.course.status == false) {
      showSnackbar(localization.Thiscoursewillbeavailableshortly);
      return;
    } else {
      context.push(
        RoutesPath.detailCourseScreen,
        extra: {
          'categoryId': widget.course.categoryId,
          'courseId': widget.course.id,
        },
      );
    }
  }
}
