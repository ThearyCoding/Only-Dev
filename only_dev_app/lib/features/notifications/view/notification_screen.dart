import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/features/notifications/provider/notification_provider.dart';
import 'package:only_dev_app/features/posts/view/post_editor_screen.dart';
import 'package:only_dev_app/generated/l10n.dart';
import 'package:only_dev_app/model/notification_model.dart';
import 'package:only_dev_app/utils/app_toast_utils.dart';
import 'package:only_dev_app/widgets/loadings-widget/build_notification_shimmer_loading.dart';
import 'package:only_dev_app/widgets/notification-widget/notification_widget.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  NotificationProvider? _provider;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      final p = _provider;
      if (p != null && p.hasMoreNotifications && !p.isLoading) {
        p.onLoading().then((_) {
          if (!p.hasMoreNotifications && mounted) {
            final localization = AppLocalizations.of(context);
            AppToastUtils.show(localization.no_more_notifications);
          }
        });
      }
    }
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
      body: Builder(
        builder: (context) {
          final provider = ref.watch(notificationNotifierProvider);
          _provider = provider;

          if (provider.isLoading && provider.notifications.isEmpty) {
            return const BuildNotificationShimmerLoading();
          }

          if (provider.notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: provider.onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Text(localization.no_notifications),
                  ),
                ),
              ),
            );
          }

          final List<NotificationModel> newNotifications =
              provider.getNewNotifications();
          final List<NotificationModel> todayNotifications =
              provider.getTodayNotifications();
          final List<NotificationModel> earlierNotifications =
              provider.getEarlierNotifications();

          return RefreshIndicator(
            onRefresh: provider.onRefresh,
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (newNotifications.isNotEmpty) ...[
                  _buildSectionHeader(localization.NEW),
                  ...newNotifications
                      .map((notification) =>
                          NotificationItem(notification: notification)),
                ],
                if (todayNotifications.isNotEmpty) ...[
                  _buildSectionHeader(localization.today),
                  ...todayNotifications
                      .map((notification) =>
                          NotificationItem(notification: notification)),
                ],
                if (earlierNotifications.isNotEmpty) ...[
                  _buildSectionHeader(localization.earlier),
                  ...earlierNotifications
                      .map((notification) =>
                          NotificationItem(notification: notification)),
                ],
                if (provider.isLoading && provider.notifications.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
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
