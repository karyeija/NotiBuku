import 'package:flutter/material.dart';

class AppColors {
  static const Color red = Colors.red;
  static const Color redAccent = Colors.redAccent;
  static const Color red400 = Color(0xFFEF5350); // example hex for red[400]

  static const Color blue = Colors.blue;
  static const Color blueAccent = Colors.blueAccent;
  static const Color blue400 = Color(0xFF42A5F5);

  static const Color pink = Colors.pink;
  static const Color pinkAccent = Colors.pinkAccent;
  static const Color pink400 = Color(0xFFEC407A);

  // Define other colors similarly

  // You can also define lists or sets of colors, e.g. for a color picker
  static final List<Color> availableColors = [
    Colors.red,
    Colors.redAccent,
    Colors.red.shade100,
    Colors.red.shade100,
    Colors.red.shade100,
    Colors.red.shade100,
    Colors.blue,
    Colors.blueAccent,
    Colors.blueGrey,
    Colors.blue.shade400,
    Colors.blue.shade300,
    Colors.blue.shade200,
    Colors.blue.shade100,
    Colors.pink,
    Colors.pinkAccent,
    Colors.pink.shade400,
    Colors.pink.shade300,
    Colors.pink.shade200,
    Colors.pink.shade100,
    Colors.amber,
    Colors.amberAccent,
    Colors.amber.shade400,
    Colors.amber.shade300,
    Colors.amber.shade200,
    Colors.amber.shade100,
    Colors.purple,
    Colors.purpleAccent,
    Colors.purple.shade400,
    Colors.purple.shade300,
    Colors.purple.shade200,
    Colors.purple.shade100,
    Colors.green,
    Colors.greenAccent,
    Colors.green.shade400,
    Colors.green.shade300,
    Colors.green.shade200,
    Colors.green.shade100,
    Colors.orange,
    Colors.orangeAccent,
    Colors.orange.shade400,
    Colors.orange.shade300,
    Colors.orange.shade200,
    Colors.orange.shade100,
  ];

  static final Set<Color> uniqueColors = availableColors.toSet();
}
