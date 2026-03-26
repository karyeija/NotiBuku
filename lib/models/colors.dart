import 'package:flutter/material.dart';

class AppColors {
  // Complete color palette with ALL shades (50-950)
  static final List<Color> availableColors = [
    // Base colors + accent
    Colors.red,
    Color.fromARGB(0, 0, 0, 0),
    Colors.redAccent,
    Color(0xFFEF5350),

    Colors.blue,
    Colors.blueAccent,
    Color(0xFF42A5F5),
    Colors.pink,
    Colors.pinkAccent,
    Color(0xFFEC407A),
    // Red - all 15 shades
    Colors.red.shade50, Colors.red.shade100, Colors.red.shade200,
    Colors.red.shade300, Colors.red.shade800,
    Colors.red.shade800, Colors.red.shade900,

    // Pink - all 15 shades
    Colors.pink.shade50, Colors.pink.shade100, Colors.pink.shade200,

    Colors.pink.shade900,

    // Purple - all 15 shades
    Colors.purple.shade50, Colors.purple.shade100, Colors.purple.shade200,
    Colors.purple.shade900,

    // Deep Purple - all 15 shades
    Colors.deepPurple.shade50, Colors.deepPurple.shade100,
    Colors.deepPurple.shade200, Colors.deepPurple.shade700,
    Colors.deepPurple.shade800, Colors.deepPurple.shade900,

    // Indigo - all 15 shades
    Colors.indigo.shade50, Colors.indigo.shade100, Colors.indigo.shade200,

    // Blue - all 15 shades
    Colors.blue.shade50, Colors.blue.shade700, Colors.blue.shade800,
    Colors.blue.shade900,

    // Light Blue - all 15 shades
    Colors.lightBlue.shade50,
    Colors.lightBlue.shade600, Colors.lightBlue.shade700,
    Colors.lightBlue.shade800, Colors.lightBlue.shade900,

    // Cyan - all 15 shades
    Colors.cyan.shade800,
    Colors.cyan.shade900,

    // Teal - all 15 shades
    Colors.teal.shade600, Colors.teal.shade700, Colors.teal.shade800,
    Colors.teal.shade900,

    // Green - all 15 shades
    Colors.green.shade50, Colors.green..shade700, Colors.green.shade800,
    Colors.green.shade900,

    // Light Green - all 15 shades
    Colors.lightGreen.shade800, Colors.lightGreen.shade900,

    // Lime - all 15 shades
    Colors.lime.shade600, Colors.lime.shade700, Colors.lime.shade800,
    Colors.lime.shade900,

    // Yellow - all 15 shades
    Colors.yellow.shade800,
    Colors.yellow.shade900,

    // Amber - all 15 shades
    Colors.amber.shade600, Colors.amber.shade700, Colors.amber.shade800,
    Colors.amber.shade900,

    // Orange - all 15 shades
    Colors.orange.shade600, Colors.orange.shade700, Colors.orange.shade800,
    Colors.orange.shade900,

    // Deep Orange - all 15 shades
    Colors.deepOrange.shade600, Colors.deepOrange.shade700,
    Colors.deepOrange.shade800, Colors.deepOrange.shade900,

    // Brown - all shades
    Colors.brown.shade600, Colors.brown.shade700, Colors.brown.shade800,
    Colors.brown.shade900,

    // Blue Grey - all shades
    Colors.blueGrey.shade800,
    Colors.blueGrey.shade900,

    // Greys - all shades
    Colors.grey.shade500,
    Colors.grey.shade600, Colors.grey.shade700, Colors.grey.shade800,
    Colors.grey.shade900,
  ];

  static final Set<Color> uniqueColors = availableColors.toSet();
}
