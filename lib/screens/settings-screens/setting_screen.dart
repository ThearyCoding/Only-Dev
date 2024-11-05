import 'package:e_leaningapp/export/curriculum_export.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../../providers/language_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  void _showLanguageDialog(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    String selectedLanguageCode = languageProvider.locale.languageCode;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Choose language'),
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: selectedLanguageCode,
              activeColor:
                  selectedLanguageCode == 'en' ? Colors.blue : Colors.grey,
              onChanged: (value) {
                languageProvider.setLocale(const Locale('en'));
                context.pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Khmer'),
              value: 'km',
              groupValue: selectedLanguageCode,
              activeColor:
                  selectedLanguageCode == 'km' ? Colors.blue : Colors.grey,
              onChanged: (value) {
                languageProvider.setLocale(const Locale('km'));
                context.pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final languageCode = languageProvider.locale.languageCode;
    final localization = S.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(S.of(context).settingsTitle),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:  const EdgeInsets.symmetric(horizontal: 16,vertical: 5),
            child: Text(
              S.of(context).languageOption,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ListTile(
            
            onTap: () {
              context.pushNamed(RoutesPath.languageSelectionScreen);
            },
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(languageCode == 'en' ? localization.english : localization.khmer),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
