import 'package:e_leaningapp/export/curriculum_export.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../../providers/language_provider.dart';
import '../../widgets/app-bar-widget/app_bar_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final languageCode = languageProvider.locale.languageCode;
    final localization = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: const AppBarWidget(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(AppLocalizations.of(context).settingsTitle),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Text(
              AppLocalizations.of(context).languageOption,
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
                title: AppLocalizations.of(context).languageOption,
                onTap: () {
                  context.pushNamed(RoutesPath.languageSelectionScreen);
                }),
          )
        ],
      ),
    );
  }
}
