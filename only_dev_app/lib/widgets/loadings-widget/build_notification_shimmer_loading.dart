import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/colors.dart';

class BuildNotificationShimmerLoading extends StatelessWidget {
  const BuildNotificationShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? baseColorDark : baseColorLight;
    final highlightColor =
        isDarkMode ? highlightColorDark : highlightColorLight;
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
            itemBuilder: (ctx, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      child: Container(
                        width: 60,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                      )),
                  const SizedBox(height: 10),
                  Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(
                      width: double.infinity,
                      height: 90,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            },
            separatorBuilder: (ctx, index) => const SizedBox(
                  height: 20,
                ),
            itemCount: 3));
  }
}
