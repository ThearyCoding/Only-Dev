// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../generated/l10n.dart';

// Custom Header Widget
class CustomizeHeader extends StatelessWidget {
  const CustomizeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ClassicHeader(
      height: 60.0,
      textStyle: TextStyle(
        fontSize: 15, 
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      releaseText: localization.releaseToRefresh,
      refreshingText: localization.pullDownToRefresh,
      completeText: localization.refreshComplete,
      failedText: localization.refreshFailed,
      idleText: localization.pullDownToRefresh,
    );
  }
}

// Custom Footer Widget
class CustomizeFooter extends StatelessWidget {
  final String noDataText;
  const CustomizeFooter({
    Key? key,
    required this.noDataText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ClassicFooter(
      height: 60.0,
      textStyle: TextStyle(
        fontSize: 15, 
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
      loadingText: localization.loadingMore,
      noDataText: localization.noMoreData(noDataText),
      idleText: localization.pullUpToLoadMore,
      failedText: localization.loadFailedTryAgain,
      canLoadingText: localization.canLoadingText,
    );
  }
}
