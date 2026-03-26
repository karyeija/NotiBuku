import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_gallery_saver/media_gallery_saver.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class Helpers {


  
  Future<bool> _requestStoragePermission() async {
    // Desktop: No permissions needed
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return true;
    }

    // Your original Android 13+ logic unchanged
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    PermissionStatus status;
    if (Platform.isAndroid) {
      status = await Permission.photos.request();
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.photos.request();
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  Future<String?> _getDesktopGalleryPath() async {
    Directory? galleryDir;

    if (Platform.isWindows) {
      galleryDir = Directory(r'C:\Users\Public\Pictures');
      if (!await galleryDir.exists()) {
        galleryDir = await getDownloadsDirectory();
      }
    } else if (Platform.isMacOS) {
      galleryDir = await getDownloadsDirectory();
    } else if (Platform.isLinux) {
      final homeDir = Platform.environment['HOME'];
      galleryDir = Directory('$homeDir/Pictures');
      if (!await galleryDir.exists()) {
        galleryDir = await getDownloadsDirectory();
      }
    }

    return galleryDir?.path;
  }

  Future<void> shareOrSaveImage(
    Uint8List imageBytes, {
    required BuildContext context,
    bool saveToGallery = false,
  }) async {
    try {
      if (saveToGallery && !(await _requestStoragePermission())) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission denied'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = '${directory.path}/notibuku_$timestamp.png';
      final file = File(imagePath);
      await file.writeAsBytes(imageBytes);

      if (saveToGallery) {
        if (Platform.isAndroid || Platform.isIOS) {
          // 🔥 Mobile: Your original media_gallery_saver code unchanged
          final saver = MediaGallerySaver();
          final success = await saver.saveMediaFromFile(file: file);
          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(' Saved to Gallery!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // Desktop: Save to Pictures/Downloads
          final galleryPath = await _getDesktopGalleryPath();
          if (galleryPath != null) {
            final desktopPath = path.join(
              galleryPath,
              'notibuku_$timestamp.png',
            );
            await file.copy(desktopPath);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(' Saved to Pictures: $galleryPath'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        }
      } else {
        // 🔥 SharePlus EXACTLY as you had it - unchanged
        try {
          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(imagePath, name: 'notibuku_note.png')],
              // text: 'Check out my NotiBuku note!',
            ),
          );
        } catch (shareError) {
          debugPrint('$shareError');
        }
      }

      await file.delete();
    } catch (e) {
      debugPrint('Share failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class AutoNumberListFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue;
  }

  static String removeNumberingFromLines(String text, int start, int end) {
    final fullLines = text.split('\n');
    final startLine = _lineIndexAtOffset(fullLines, start);
    final endLine = _lineIndexAtOffset(fullLines, end);

    final cleanedLines = <String>[];
    for (int i = 0; i < fullLines.length; i++) {
      if (i >= startLine && i <= endLine) {
        final line = fullLines[i];
        // Fixed: Only remove if line actually has numbering, preserve original spaces
        final cleaned = RegExp(r'^\s*\d+\.\s*').hasMatch(line)
            ? line.replaceAll(RegExp(r'^\s*\d+\.\s*'), '')
            : line;
        cleanedLines.add(cleaned);
      } else {
        cleanedLines.add(fullLines[i]);
      }
    }
    return cleanedLines.join('\n');
  }

  // ethod to number/denumber selected content
  static String numberSelectedLines(String text, int start, int end) {
    final fullLines = text.split('\n');
    final startLine = _lineIndexAtOffset(fullLines, start);
    final endLine = _lineIndexAtOffset(fullLines, end);

    final numberedLines = <String>[];
    int nextNumber = 1;

    for (int i = 0; i < fullLines.length; i++) {
      final originalLine = fullLines[i];

      if (i >= startLine && i <= endLine) {
        // Fixed: Skip empty lines and only number lines with actual content
        if (_isEmptyOrJustSpaces(originalLine)) {
          numberedLines.add(originalLine);
          continue;
        }

        // Check if already numbered
        if (RegExp(r'^\s*\d+\.\s').hasMatch(originalLine)) {
          // Preserve existing numbering and continue sequence
          final match = RegExp(r'^\s*(\d+)').firstMatch(originalLine);
          if (match != null) {
            nextNumber = int.parse(match.group(1)!) + 1;
          }
          numberedLines.add(originalLine);
        } else {
          // Number this line, preserve original leading spaces
          final leadingSpaces =
              RegExp(r'^(\s*)').firstMatch(originalLine)?.group(1) ?? '';
          final content = originalLine.trim();
          numberedLines.add('$leadingSpaces$nextNumber. $content');
          nextNumber++;
        }
      } else {
        // Update nextNumber counter for existing numbered lines outside selection
        if (RegExp(r'^\s*\d+\.\s').hasMatch(originalLine)) {
          final match = RegExp(r'^\s*(\d+)').firstMatch(originalLine);
          if (match != null) {
            nextNumber = int.parse(match.group(1)!) + 1;
          }
        }
        numberedLines.add(originalLine);
      }
    }

    return numberedLines.join('\n');
  }

  // Helper: Check if line is empty or just whitespace
  static bool _isEmptyOrJustSpaces(String line) {
    return line.trim().isEmpty || line.trim() == '';
  }

  static int _lineIndexAtOffset(List<String> lines, int offset) {
    int currentOffset = 0;
    for (int i = 0; i < lines.length; i++) {
      if (offset <= currentOffset + lines[i].length) return i;
      currentOffset += lines[i].length + 1; // +1 for newline
    }
    return lines.length - 1;
  }
}
