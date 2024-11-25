import 'package:e_leaningapp/export/app_routes_export.dart';
import 'package:flutter/material.dart';
import '../../generated/l10n.dart';

class AppBarWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;

  const AppBarWidget({
    Key? key,
    this.onTap,
    this.icon = Icons.arrow_back_ios,
    this.iconSize = 24.0,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      iconSize: iconSize,
      splashRadius: 20,
      tooltip: AppLocalizations.of(context).back,
      onPressed: onTap ?? () => context.pop(),
      icon: Icon(
        icon,
        color: iconColor ?? (isDarkMode ? Colors.white : Colors.black),
      ),
    );
  }
}
