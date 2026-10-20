import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/generated/l10n.dart';
import 'package:only_dev_app/routes/app_routes.dart';
import 'package:only_dev_app/widgets/app-bar-widget/app_bar_widget.dart';
import 'package:only_dev_app/widgets/list-widget/custom_list_tile_widget.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageProvider = ref.watch(languageNotifierProvider);
    final languageCode = languageProvider.locale.languageCode;
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: const AppBarWidget(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(localization.settingsTitle),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Text(
              localization.languageOption,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CustomListTile(
              trailingText: languageCode == 'en'
                  ? localization.english
                  : localization.khmer,
              leadingIcon: const Icon(Icons.language),
              title: localization.languageOption,
              onTap: () {
                context.pushNamed(RoutesPath.languageSelectionScreen);
              },
            ),
          ),
        ],
      ),
    );
  }
}
