import 'package:e_leaningapp/generated/l10n.dart';
import 'package:e_leaningapp/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DisEnableNotificationScreen extends StatelessWidget {
  const DisEnableNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<NotificationProvider>(context, listen: false);
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
              onPressed: () {
               // NavigationService.instance.pushMaterialRoute(const CachePage());

              },
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
        body: Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            return SwitchListTile(
              title: const Text('Enable Notifications'),
              value: provider.notificationsEnabled,
              onChanged: (bool value) {
                provider.updateNotificationPreference(value);
              },
            );
          },
        ));
  }
}
