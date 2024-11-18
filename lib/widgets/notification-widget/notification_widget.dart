import 'dart:developer';

import 'package:e_leaningapp/export/curriculum_export.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../model/notification_model.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationItem({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ZoomTapAnimation(
     // onLongTap: ()=> navigation(context),
      onTap: ()=> navigation(context),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 5,
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isDarkMode
                  ? Colors.orange.shade400.withOpacity(.3)
                  : Colors.green.shade400,
            ),
            child: Icon(
              IconlyBold.notification,
              color: isDarkMode ? Colors.white : Colors.grey.shade200,
            ),
          ),
          title: Text(
            notification.post == null
                ? notification.title
                : notification.post!.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (notification.post == null)
                Text(
                  notification.message,
                  maxLines: 2,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              if (notification.post != null) ...[
                Text(
                  notification.post!.contentPreview,
                  maxLines: 1,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
              const SizedBox(height: 4.0),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  notification.timestamp != null
                      ? DateFormat('EEE /MMM/yy: h:mm a').format(notification.timestamp)

                      : 'No Date',
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    color: isDarkMode ? Colors.white54 : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 void navigation(BuildContext context) {
    log('notification type : $notification');
    if (notification.type == "course") {
      context.push(
        RoutesPath.detailCourseScreen,
        extra: {
          'categoryId': notification.categoryId,
          'courseId': notification.courseId,
        },
      );
    } else if (notification.type == "announcement") {
      context.push(RoutesPath.postDetailsScreen, extra: {
        'postId': notification.postId,
      });
    }
  }
}
