import 'package:e_leaningapp/export/export.dart';
import 'package:flutter/material.dart';
import '../../core/colors.dart';

class BuildCategoriesShimmerWidget extends StatelessWidget {
  const BuildCategoriesShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDarkMode ? baseColorDark : baseColorLight,
      highlightColor: isDarkMode ? highlightColorDark : highlightColorLight,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 15.0),
            padding: EdgeInsets.only(
              left: index == 0 ? 10.0 : 0.0,
              top: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(width: 5);
        },
      ),
    );
  }
}
