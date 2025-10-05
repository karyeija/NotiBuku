import 'package:flutter/widgets.dart';

double getSizeFactor(BuildContext context) {
  double pageHeight = MediaQuery.of(context).size.height;
  double pageWidth = MediaQuery.of(context).size.width;

  return pageHeight > pageWidth ? pageHeight : pageWidth;
}
