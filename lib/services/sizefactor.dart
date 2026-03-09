import 'package:flutter/widgets.dart';

double getSizeFactor(BuildContext context) {
  double pageHeight = MediaQuery.of(context).size.height;
  double pageWidth = MediaQuery.of(context).size.width;

  return pageHeight > pageWidth ? pageHeight : pageWidth;
}

class Func {
  double screenHeight(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return screenHeight;
  }

  double screenWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return screenWidth;
  }
}
