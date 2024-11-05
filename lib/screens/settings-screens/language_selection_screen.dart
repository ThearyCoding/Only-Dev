import 'package:e_leaningapp/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localization = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title:  Text(localization.chooseLanguage),
      ),
      body: ListView(
        children: [
          ListTile(
            title:  Text(localization.english),
            trailing: languageProvider.locale.languageCode == 'en'
                ? const Icon(Icons.check, color: Colors.blue)
                : null,
            onTap: () {
              languageProvider.setLocale(const Locale('en'));
            },
          ),
          ListTile(
            title:  Text(localization.khmer),
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
