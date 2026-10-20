import 'package:flutter/material.dart';
import '../app_widgets/app_image_widget.dart';
import '../../model/category_model.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final double widgetWidth;
  final double fontSize;

  const CategoryCard({Key? key, required this.category, required this.widgetWidth, required this.fontSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widgetWidth,
      margin: const EdgeInsets.only(right: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          AppImageWidget(
            imageUrl: category.imageUrl,
            blurHash: category.blurHash,
            borderRadius: BorderRadius.circular(15),
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
            fallbackIcon: Icons.category_outlined,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .5),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Text(
                category.title,
                maxLines: 1,
                style:  TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                  overflow: TextOverflow.ellipsis,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
