// import 'package:flutter/material.dart';

// class LinedTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final int maxLines;

//   LinedTextField({required this.controller, this.maxLines = 5});

//   @override
//   Widget build(BuildContext context) {
//     final lineHeight = 24.0; // approximate height of one line of text

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final linesCount = maxLines;
//         return Stack(
//           children: [
//             // Draw lines
//             CustomPaint(
//               size: Size(constraints.maxWidth, linesCount * lineHeight),
//               painter: _LinePainter(lineHeight, linesCount),
//             ),
//             // Text field with transparent background
//             TextFormField(
//               controller: controller,
//               maxLines: maxLines,
//               style: TextStyle(height: 1.0), // line spacing
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.transparent,
//                 border: InputBorder.none,
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class _LinePainter extends CustomPainter {
//   final double lineHeight;
//   final int linesCount;

//   _LinePainter(this.lineHeight, this.linesCount);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.grey[300]!
//       ..strokeWidth = 1.0;

//     for (int i = 1; i <= linesCount; i++) {
//       final y = i * lineHeight;
//       canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
