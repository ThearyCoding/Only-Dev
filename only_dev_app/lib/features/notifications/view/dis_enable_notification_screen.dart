import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/generated/l10n.dart';

class DisEnableNotificationScreen extends ConsumerWidget {
  const DisEnableNotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(notificationNotifierProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final localization = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            localization.notificationsTitle,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.cached),
            )
          ],
          leading: IconButton(
              splashRadius: 20,
              onPressed: () {
                context.pop();
              },
              tooltip: localization.back,
              icon: Icon(
                color: isDarkMode ? Colors.white : Colors.black,
                Icons.arrow_back_ios,
                size: 16,
              )),
        ),
        body: SwitchListTile(
          title: const Text('Enable Notifications'),
          value: provider.notificationsEnabled,
          onChanged: (bool value) {
            provider.updateNotificationPreference(value);
          },
        ));
  }
}
