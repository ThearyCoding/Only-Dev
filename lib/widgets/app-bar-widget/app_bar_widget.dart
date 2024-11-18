import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../generated/l10n.dart';
class AppBarWidget extends StatelessWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      iconSize: 16,
      splashRadius: 20,
      tooltip: AppLocalizations.of(context).back,
      onPressed: (){
      context.pop();
    }, icon:  Icon(Icons.arrow_back_ios,color: isDarkMode ? Colors.white : Colors.black,));
  }
}