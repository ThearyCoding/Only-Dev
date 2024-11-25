import 'package:e_leaningapp/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/colors.dart';

class CourseShimmerLoadingWidget extends StatelessWidget {
  final int itemCount;
  const CourseShimmerLoadingWidget({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? baseColorDark : baseColorLight;

    final highlightColor =
        isDarkMode ? highlightColorDark : highlightColorLight;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getCrossAxisCount(context),
        childAspectRatio: getChildAspectRatio(context),
        crossAxisSpacing: getCrossAxisSpacing(context),
        mainAxisSpacing: getMainAxisSpacing(context),
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              // borderRadius: BorderRadius.circular(8),
            ),
            //  margin: const EdgeInsets.all(8),
          ),
        );
      },
    );
  }
}
