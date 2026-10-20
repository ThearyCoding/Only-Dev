import 'package:flutter/material.dart';
import '../app_widgets/app_image_widget.dart';

class ShimmerImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit fit;

  const ShimmerImage({
    super.key,
    required this.imageUrl,
    required this.height,
    required this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return AppImageWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
