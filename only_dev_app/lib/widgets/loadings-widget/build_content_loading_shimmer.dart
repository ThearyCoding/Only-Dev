import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/colors.dart';

class BuildContentLoadingShimmer extends StatelessWidget {
  const BuildContentLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
    baseColor: isDarkMode ? baseColorDark : baseColorLight,
    highlightColor: isDarkMode ? highlightColorDark : highlightColorLight,
    child: ListView.builder(
      itemCount: 5,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Container(
          height: 100,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
  }
}