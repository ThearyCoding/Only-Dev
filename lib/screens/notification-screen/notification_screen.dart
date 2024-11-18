import 'package:e_leaningapp/generated/l10n.dart';
import 'package:e_leaningapp/utils/show_error_utils.dart';
import 'package:e_leaningapp/widgets/loadings/custom_smart_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../model/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/loadings/build_notification_shimmer_loading.dart';
import '../../widgets/notification-widget/notification_widget.dart';
import '../post_editor_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late RefreshController _refreshController;
  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localization = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
       localization.notifications,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PostEditorScreen()),
              );
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const BuildNotificationShimmerLoading();
          }
          List<NotificationModel> newNotifications =
              provider.getNewNotifications();
          List<NotificationModel> todayNotifications =
              provider.getTodayNotifications();
          List<NotificationModel> earlierNotifications =
              provider.getEarlierNotifications();
          return SmartRefresher(
            controller: _refreshController,
            enablePullUp: true,
            header: const CustomizeHeader(),
            footer:  CustomizeFooter(
              noDataText: localization.notifications
            ),
            onRefresh: () async {
              _refreshController.loadComplete();
              await provider.onRefresh();
              _refreshController.refreshCompleted();
            },
            onLoading: () async {
              await _refreshController.requestLoading();
              await provider.onLoading();
              _refreshController.loadComplete();
              if (!provider.hasMoreNotifications) {
               showSnackbar(localization.no_more_notifications);
                _refreshController.loadNoData();
                return;
              }
            },
            child: provider.notifications.isEmpty
                ?  Center(
                    child: Text(localization.no_notifications),
                  )
                : ListView(
                    children: [
                      if (newNotifications.isNotEmpty) ...[
                        _buildSectionHeader(localization.NEW),
                        ...newNotifications
                            .map((notification) =>
                                NotificationItem(notification: notification))
                            .toList(),
                      ],
                      if (todayNotifications.isNotEmpty) ...[
                        _buildSectionHeader(localization.today),
                        ...todayNotifications
                            .map((notification) =>
                                NotificationItem(notification: notification))
                            .toList(),
                      ],
                      if (earlierNotifications.isNotEmpty) ...[
                        _buildSectionHeader(localization.earlier),
                        ...earlierNotifications
                            .map((notification) =>
                                NotificationItem(notification: notification))
                            .toList(),
                      ],
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
