import 'package:e_leaningapp/generated/l10n.dart';
import 'package:e_leaningapp/widgets/app-bar-widget/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
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
