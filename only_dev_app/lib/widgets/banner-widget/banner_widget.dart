import 'package:carousel_slider/carousel_slider.dart';
import 'package:only_dev_app/features/courses/provider/banners_provider.dart';
import 'package:only_dev_app/utils/app_toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../app_widgets/app_image_widget.dart';

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
                          AppToastUtils.info('tap on banner');
                        },
                        child: Container(
                          width: constraints.maxWidth,
                          margin: const EdgeInsets.symmetric(horizontal: 2.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: AppImageWidget(
                            imageUrl: banner.imageUrl,
                            width: constraints.maxWidth,
                            height: height,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(10),
                            fallbackIcon: Icons.campaign_outlined,
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
