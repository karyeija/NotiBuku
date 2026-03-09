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
    Colors.red.shade300, Colors.red.shade400, Colors.red.shade500,
    Colors.red.shade600, Colors.red.shade700, Colors.red.shade800,
    Colors.red.shade800, Colors.red.shade900,

    // Pink - all 15 shades
    Colors.pink.shade50, Colors.pink.shade100, Colors.pink.shade200,
    Colors.pink.shade300, Colors.pink.shade400, Colors.pink.shade500,
    Colors.pink.shade600, Colors.pink.shade700, Colors.pink.shade800,
    Colors.pink.shade900,

    // Purple - all 15 shades
    Colors.purple.shade50, Colors.purple.shade100, Colors.purple.shade200,
    Colors.purple.shade300, Colors.purple.shade400, Colors.purple.shade500,
    Colors.purple.shade600, Colors.purple.shade700, Colors.purple.shade800,
    Colors.purple.shade900,

    // Deep Purple - all 15 shades
    Colors.deepPurple.shade50, Colors.deepPurple.shade100,
    Colors.deepPurple.shade200, Colors.deepPurple.shade300,
    Colors.deepPurple.shade400, Colors.deepPurple.shade500,
    Colors.deepPurple.shade600, Colors.deepPurple.shade700,
    Colors.deepPurple.shade800, Colors.deepPurple.shade900,

    // Indigo - all 15 shades
    Colors.indigo.shade50, Colors.indigo.shade100, Colors.indigo.shade200,
    Colors.indigo.shade300, Colors.indigo.shade400, Colors.indigo.shade500,
    Colors.indigo.shade600, Colors.indigo.shade700, Colors.indigo.shade800,
    Colors.indigo.shade900,

    // Blue - all 15 shades
    Colors.blue.shade50, Colors.blue.shade100, Colors.blue.shade200,
    Colors.blue.shade300, Colors.blue.shade400, Colors.blue.shade500,
    Colors.blue.shade600, Colors.blue.shade700, Colors.blue.shade800,
    Colors.blue.shade900,

    // Light Blue - all 15 shades
    Colors.lightBlue.shade50, Colors.lightBlue.shade100,
    Colors.lightBlue.shade200, Colors.lightBlue.shade300,
    Colors.lightBlue.shade400, Colors.lightBlue.shade500,
    Colors.lightBlue.shade600, Colors.lightBlue.shade700,
    Colors.lightBlue.shade800, Colors.lightBlue.shade900,

    // Cyan - all 15 shades
    Colors.cyan.shade50, Colors.cyan.shade100, Colors.cyan.shade200,
    Colors.cyan.shade300, Colors.cyan.shade400, Colors.cyan.shade500,
    Colors.cyan.shade600, Colors.cyan.shade700, Colors.cyan.shade800,
    Colors.cyan.shade900,

    // Teal - all 15 shades
    Colors.teal.shade50, Colors.teal.shade100, Colors.teal.shade200,
    Colors.teal.shade300, Colors.teal.shade400, Colors.teal.shade500,
    Colors.teal.shade600, Colors.teal.shade700, Colors.teal.shade800,
    Colors.teal.shade900,

    // Green - all 15 shades
    Colors.green.shade50, Colors.green.shade100, Colors.green.shade200,
    Colors.green.shade300, Colors.green.shade400, Colors.green.shade500,
    Colors.green.shade600, Colors.green.shade700, Colors.green.shade800,
    Colors.green.shade900,

    // Light Green - all 15 shades
    Colors.lightGreen.shade50, Colors.lightGreen.shade100,
    Colors.lightGreen.shade200, Colors.lightGreen.shade300,
    Colors.lightGreen.shade400, Colors.lightGreen.shade500,
    Colors.lightGreen.shade600, Colors.lightGreen.shade700,
    Colors.lightGreen.shade800, Colors.lightGreen.shade900,

    // Lime - all 15 shades
    Colors.lime.shade50, Colors.lime.shade100, Colors.lime.shade200,
    Colors.lime.shade300, Colors.lime.shade400, Colors.lime.shade500,
    Colors.lime.shade600, Colors.lime.shade700, Colors.lime.shade800,
    Colors.lime.shade900,

    // Yellow - all 15 shades
    Colors.yellow.shade50, Colors.yellow.shade100, Colors.yellow.shade200,
    Colors.yellow.shade300, Colors.yellow.shade400, Colors.yellow.shade500,
    Colors.yellow.shade600, Colors.yellow.shade700, Colors.yellow.shade800,
    Colors.yellow.shade900,

    // Amber - all 15 shades
    Colors.amber.shade50, Colors.amber.shade100, Colors.amber.shade200,
    Colors.amber.shade300, Colors.amber.shade400, Colors.amber.shade500,
    Colors.amber.shade600, Colors.amber.shade700, Colors.amber.shade800,
    Colors.amber.shade900,

    // Orange - all 15 shades
    Colors.orange.shade50, Colors.orange.shade100, Colors.orange.shade200,
    Colors.orange.shade300, Colors.orange.shade400, Colors.orange.shade500,
    Colors.orange.shade600, Colors.orange.shade700, Colors.orange.shade800,
    Colors.orange.shade900,

    // Deep Orange - all 15 shades
    Colors.deepOrange.shade50, Colors.deepOrange.shade100,
    Colors.deepOrange.shade200, Colors.deepOrange.shade300,
    Colors.deepOrange.shade400, Colors.deepOrange.shade500,
    Colors.deepOrange.shade600, Colors.deepOrange.shade700,
    Colors.deepOrange.shade800, Colors.deepOrange.shade900,

    // Brown - all shades
    Colors.brown.shade50, Colors.brown.shade100, Colors.brown.shade200,
    Colors.brown.shade300, Colors.brown.shade400, Colors.brown.shade500,
    Colors.brown.shade600, Colors.brown.shade700, Colors.brown.shade800,
    Colors.brown.shade900,

    // Blue Grey - all shades
    Colors.blueGrey.shade50, Colors.blueGrey.shade100, Colors.blueGrey.shade200,
    Colors.blueGrey.shade300,
    Colors.blueGrey.shade400,
    Colors.blueGrey.shade500,
    Colors.blueGrey.shade600,
    Colors.blueGrey.shade700,
    Colors.blueGrey.shade800,
    Colors.blueGrey.shade900,

    // Greys - all shades
    Colors.grey.shade50, Colors.grey.shade100, Colors.grey.shade200,
    Colors.grey.shade300, Colors.grey.shade400, Colors.grey.shade500,
    Colors.grey.shade600, Colors.grey.shade700, Colors.grey.shade800,
    Colors.grey.shade900,
  ];

  static final Set<Color> uniqueColors = availableColors.toSet();
}
