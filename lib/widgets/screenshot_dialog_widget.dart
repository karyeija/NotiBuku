// lib/widgets/screenshot_dialog_widget.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:notibuku/utils/helpers.dart';

class ScreenshotDialog extends StatelessWidget {
  final Uint8List image;
  final BuildContext parentContext;
  final bool parentMounted;

  const ScreenshotDialog({
    super.key,
    required this.image,
    required this.parentContext,
    required this.parentMounted,
  });

  Future<void> _handleSave(BuildContext dialogContext) async {
    Navigator.of(dialogContext).pop();
    await Helpers().shareOrSaveImage(
      context: parentContext,
      image,
      saveToGallery: true,
    );
    _showSnackBar(
      Icons.check_circle,
      'Screenshot saved to gallery!',
      Colors.green,
    );
  }

  Future<void> _handleShare(BuildContext dialogContext) async {
    Navigator.of(dialogContext).pop();
    await Helpers().shareOrSaveImage(context: parentContext, image);
    _showSnackBar(Icons.share, 'Screenshot shared successfully!', Colors.blue);
  }

  void _showSnackBar(IconData icon, String message, Color color) {
    if (parentMounted && parentContext.mounted) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Note Preview')),
      body: Stack(
        children: [
          // Screenshot preview
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.memory(image),
            ),
          ),
          // Action buttons
          Positioned(
            bottom: 100,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'save',
                  backgroundColor: Colors.green,
                  onPressed: () => _handleSave(context),
                  child: const Icon(Icons.download),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'share',
                  backgroundColor: Colors.blue,
                  onPressed: () => _handleShare(context),
                  child: const Icon(Icons.share),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
