import '../../core/colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BuildShimmerCourseCardV2 extends StatelessWidget {
  const BuildShimmerCourseCardV2({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return buildShimmerPlaceholder(context);
      },
    );
  }

  Widget buildShimmerPlaceholder(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDarkMode ? baseColorDark : baseColorLight,
      highlightColor: isDarkMode ? highlightColorDark : highlightColorLight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 120,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Container(
              width: 200,
              height: 16,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Container(
              width: 300,
              height: 12,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 100,
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Container(
                  width: 100,
                  height: 16,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(width: 8),
                Container(
                  width: 100,
                  height: 16,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 100,
                  height: 40,
                  color: Colors.white,
                ),
                Container(
                  width: 50,
                  height: 24,
                  color: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
