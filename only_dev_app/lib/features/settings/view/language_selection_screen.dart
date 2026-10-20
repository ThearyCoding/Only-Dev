import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/generated/l10n.dart';
import 'package:only_dev_app/widgets/app-bar-widget/app_bar_widget.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageProvider = ref.watch(languageNotifierProvider);
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: const AppBarWidget(),
        title: Text(localization.chooseLanguage),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text(localization.english),
            trailing: languageProvider.locale.languageCode == 'en'
                ? const Icon(Icons.check, color: Colors.blue)
                : null,
            onTap: () {
              languageProvider.setLocale(const Locale('en'));
            },
          ),
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text(localization.khmer),
            trailing: languageProvider.locale.languageCode == 'km'
                ? const Icon(Icons.check, color: Colors.blue)
                : null,
            onTap: () {
              languageProvider.setLocale(const Locale('km'));
            },
          ),
        ],
      ),
    );
  }
}
