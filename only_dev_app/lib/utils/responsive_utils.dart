import 'package:flutter/material.dart';

double getResponsiveFontSize(BuildContext context, double baseSize) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth >= 1200) {
    return baseSize; // Desktop
  } else if (screenWidth >= 800) {
    return baseSize * 0.9; // Tablet
  } else if (screenWidth >= 600) {
    return baseSize * 0.8; // Large Mobile
  } else {
    return baseSize * 0.7; // Small Mobile
  }
}

double getResponsiveWidth(BuildContext context, double baseWidth) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth >= 1200) {
    return baseWidth; // Desktop
  } else if (screenWidth >= 800) {
    return baseWidth * 0.9; // Tablet
  } else if (screenWidth >= 600) {
    return baseWidth * 0.8; // Large Mobile
  } else {
    return baseWidth * 0.7; // Small Mobile
  }
}

double getResponsiveHeight(BuildContext context, double baseHeight) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth >= 1200) {
    return baseHeight; // Desktop
  } else if (screenWidth >= 800) {
    return baseHeight * 0.9; // Tablet
  } else if (screenWidth >= 600) {
    return baseHeight * 0.8; // Large Mobile
  } else {
    return baseHeight * 0.7; // Small Mobile
  }
}

int getCrossAxisCount(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth >= 1200) {
    return 4; // Desktop
  } else if (screenWidth >= 600) {
    return 3; // Tablet
  } else {
    return 2; // Mobile
  }
}

double getChildAspectRatio(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth >= 1200) {
    return 1.0; // Desktop
  } else if (screenWidth >= 800) {
    return 0.7; // Tablet
  } else if (screenWidth >= 600) {
    return 0.9; // Large Mobile
  } else if (screenWidth >= 400) {
    return 0.96; // Middle Mobile
  } else if (screenWidth >= 300) {
    if (screenWidth >= 380) {
      return 0.88; // Smaller Mobile
    } else {
      return 0.84;
    }
  } else {
    return 0.92; // Smallest Mobile
  }
}

double getCrossAxisSpacing(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth >= 1200) {
    return 16.0; // Desktop
  } else if (screenWidth >= 800) {
    return 12.0; // Tablet
  } else {
    return 8.0; // Mobile
  }
}

double getMainAxisSpacing(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth >= 1200) {
    return 16.0; // Desktop
  } else if (screenWidth >= 800) {
    return 12.0; // Tablet
  } else {
    return 8.0; // Mobile
  }
}
