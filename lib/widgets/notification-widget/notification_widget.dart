import 'package:e_leaningapp/export/curriculum_export.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../model/notification_model.dart';
import '../../providers/notification_provider.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationItem({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final notificationColor = notification.isDetailSeen
        ? (isDarkMode ? Colors.green.shade400 : Colors.blue.shade100)
        : (isDarkMode
            ? Colors.orange.shade400.withValues(alpha: 0.3)
            : Colors.green.shade400);

    return ZoomTapAnimation(
      onTap: () async {
        navigation(context);
        await context
            .read<NotificationProvider>()
            .toggleDetailSeen(notification.id, true);
      },
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
              color: notificationColor,
            ),
            child: Icon(
              IconlyBold.notification,
              color: isDarkMode ? Colors.white : Colors.grey.shade200,
            ),
          ),
          trailing: IconButton(
            splashRadius: 20,
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              showBottomSheet(context, notification.id);
              
            },
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
                      ? DateFormat('EEE /MMM/yy: h:mm a')
                          .format(notification.timestamp)
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

 void showBottomSheet(BuildContext context, String notificationId) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (ctx) {
      final screenHeight = MediaQuery.of(context).size.height;
      return Container(
        height: screenHeight * 0.55,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              spreadRadius: 5,
              blurRadius: 15,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDarkMode
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Manage Notification",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 15),
            ListView.builder(
              itemCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, index) {
                return Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: isDarkMode ? Colors.grey.shade800 : Colors.blue.shade50,
                      child: ListTile(
                        onTap: () async {
                          if (index == 0) {
                            await context
                                .read<NotificationProvider>()
                                .deleteNotification(notificationId);
                            showSnackbar("Notification deleted successfully");
                           
                          } else {
                            showSnackbar("Reported successfully");
                          }
                           if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        title: Text(
                          index == 0 ? "Delete Notification" : "Report this Notification",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        leading: Icon(
                          index == 0 ? Icons.delete_forever : Icons.report,
                          color: isDarkMode ? Colors.white : Colors.blue,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        index == 0
                            ? "Permanently remove this notification from your list."
                            : "Send a report about this notification for review.",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

}
