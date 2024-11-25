import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/colors.dart';

class BuildTapShimmerWidget extends StatelessWidget {
  const BuildTapShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDarkMode ? baseColorDark : baseColorLight,
      highlightColor: isDarkMode ? highlightColorDark : highlightColorLight,
      child: SizedBox(
        width: double.infinity,
        height: 30,
        child: ListView.separated(
          shrinkWrap: false,
          physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (ctx, index) {
              return Container(
                width: 100,
                height: 20,
                decoration:  BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10)),
              );
            },
            separatorBuilder: (ctx, index) => const SizedBox(
                  width: 10,
                ),
            itemCount: 4),
      ),
    );
  }
}
