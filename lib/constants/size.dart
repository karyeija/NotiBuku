import 'package:flutter/material.dart';

class Scale {
  // Static method - pass context from widget tree
  static double getScale(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Aspect ratio: width/height (standard approach)
    return screenWidth / screenHeight;
  }

  // Reference scale (e.g., iPhone 14 baseline: 390x844 = ~0.46)
  static const double referenceScale = 0.46;

  // Scaling factor relative to reference
  static double getScalingFactor(BuildContext context) {
    return getScale(context) / referenceScale;
  }
}
