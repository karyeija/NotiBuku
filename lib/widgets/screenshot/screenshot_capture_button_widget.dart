import 'package:flutter/material.dart';

class ScreenshotCaptureButton extends StatelessWidget {
  final bool isCapturing;
  final VoidCallback? onCapture;
  final double iconSizeFactor; // e.g., 0.09 of screen width
  final Color enabledColor;
  final Color disabledColor;
  final Color backgroundColor;
  final double borderRadius;
  final double elevation;

  const ScreenshotCaptureButton({
    super.key,
    required this.isCapturing,
    required this.onCapture,
    this.iconSizeFactor = 0.09,
    this.enabledColor = Colors.black87,
    this.disabledColor = Colors.orange,
    this.backgroundColor = Colors.white,
    this.borderRadius = double.infinity,
    this.elevation = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double iconSize = screenWidth * iconSizeFactor;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.9),
        shape: borderRadius == double.infinity
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: borderRadius == double.infinity
            ? null
            : BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: isCapturing ? null : onCapture,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          transform: Matrix4.identity()
            ..scaledByDouble(isCapturing ? 0.9 : 1.0, 1, 1, 1),
          child: RotatedBox(
            quarterTurns: 1,
            child: Icon(
              isCapturing ? Icons.screenshot : Icons.screenshot_outlined,
              color: isCapturing ? disabledColor : enabledColor,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
