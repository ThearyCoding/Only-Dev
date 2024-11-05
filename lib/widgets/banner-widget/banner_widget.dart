import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_leaningapp/providers/banners_provider.dart';
import 'package:e_leaningapp/utils/show_error_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../export/export.dart';

class BannerWidget extends StatelessWidget {
  const BannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final BannersProvider bannerController =
        Provider.of<BannersProvider>(context);
    return Consumer<BannersProvider>(
      builder: (context, value, child) {
        if (bannerController.isLoading) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: 90.0,
              color: Colors.white,
            ),
          );
        } else if (bannerController.banners.isEmpty) {
          return LayoutBuilder(builder: (context, constraints) {
            double height;
            if (constraints.maxWidth < 360) {
              // Small mobile devices
              height = 90.0;
            } else if (constraints.maxWidth < 480) {
              // Medium mobile devices
              height = 100.0;
            } else if (constraints.maxWidth < 600) {
              // Large mobile devices
              height = 110.0;
            } else {
              // Tablets
              height = 140.0;
            }
            return Container(
                width: constraints.maxWidth,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                child: const Center(child: Text("No Banners Found!")));
          });
        } else {
          return LayoutBuilder(
            builder: (context, constraints) {
              double height;
              if (constraints.maxWidth < 360) {
                // Small mobile devices
                height = 90.0;
              } else if (constraints.maxWidth < 480) {
                // Medium mobile devices
                height = 100.0;
              } else if (constraints.maxWidth < 600) {
                // Large mobile devices
                height = 110.0;
              } else {
                // Tablets
                height = 140.0;
              }

              return CarouselSlider(
                options: CarouselOptions(
                  viewportFraction: 1,
                  height: height,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  padEnds: false,
                ),
                items: bannerController.banners.map((banner) {
                  return Builder(
                    builder: (BuildContext context) {
                      return GestureDetector(
                        onTap: () {
                          showSnackbar('tap on banner');
                        },
                        child: Container(
                          width: constraints.maxWidth,
                          margin: const EdgeInsets.symmetric(horizontal: 2.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: banner.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) {
                                final isDarkMode =
                                    Theme.of(context).brightness ==
                                        Brightness.dark;
                                return Shimmer.fromColors(
                                  baseColor: isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!,
                                  highlightColor: isDarkMode
                                      ? Colors.grey[500]!
                                      : Colors.grey[100]!,
                                  child: Container(
                                    width: constraints.maxWidth,
                                    height: height,
                                    color: Colors.white,
                                  ),
                                );
                              },
                              errorWidget: (context, url, error) => Container(
                                width: constraints.maxWidth,
                                height: height,
                                color: Colors.grey,
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          );
        }
      },
    );
  }
}
