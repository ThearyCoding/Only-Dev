import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:only_dev_app/routes/app_routes.dart';
import 'package:only_dev_app/utils/auth_guard_utils.dart';

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
          if (!AuthGuard.isAuthenticated()) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        size: 42,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Stay in the Loop',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sign in to receive updates about your enrolled courses, new lectures, and quiz results.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 200,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push(RoutesPath.login),
                        icon: const Icon(Icons.login_rounded, size: 18),
                        label: const Text('Sign In'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

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
