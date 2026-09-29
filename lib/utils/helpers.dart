import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_gallery_saver/media_gallery_saver.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class Helpers {
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

      if (homeDir != null) {
        galleryDir = Directory('$homeDir/Pictures');
      }

      if (galleryDir == null || !await galleryDir.exists()) {
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
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = path.join(directory.path, 'notibuku_$timestamp.png');

      final file = File(imagePath);
      await file.writeAsBytes(imageBytes);

      if (saveToGallery) {
        if (Platform.isAndroid || Platform.isIOS) {
          final saver = MediaGallerySaver();

          final success = await saver.saveMediaFromFile(file: file);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Saved to Gallery!'
                      : 'Failed to save image to Gallery.',
                ),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
          }
        } else {
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
                  content: Text('Saved to Pictures: $galleryPath'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        }
      } else {
        try {
          await SharePlus.instance.share(
            ShareParams(files: [XFile(imagePath, name: 'notibuku_note.png')]),
          );
        } catch (shareError) {
          debugPrint('$shareError');
        }
      }

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Share/save failed: $e');

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

        final cleaned = RegExp(r'^\s*\d+\.\s*').hasMatch(line)
            ? line.replaceFirst(RegExp(r'^\s*\d+\.\s*'), '')
            : line;

        cleanedLines.add(cleaned);
      } else {
        cleanedLines.add(fullLines[i]);
      }
    }

    return cleanedLines.join('\n');
  }

  static String numberSelectedLines(String text, int start, int end) {
    final fullLines = text.split('\n');

    final startLine = _lineIndexAtOffset(fullLines, start);
    final endLine = _lineIndexAtOffset(fullLines, end);

    final numberedLines = <String>[];
    int nextNumber = 1;

    for (int i = 0; i < fullLines.length; i++) {
      final originalLine = fullLines[i];

      if (i >= startLine && i <= endLine) {
        if (_isEmptyOrJustSpaces(originalLine)) {
          numberedLines.add(originalLine);
          continue;
        }

        if (RegExp(r'^\s*\d+\.\s').hasMatch(originalLine)) {
          final match = RegExp(r'^\s*(\d+)').firstMatch(originalLine);

          if (match != null) {
            nextNumber = int.parse(match.group(1)!) + 1;
          }

          numberedLines.add(originalLine);
        } else {
          final leadingSpaces =
              RegExp(r'^(\s*)').firstMatch(originalLine)?.group(1) ?? '';

          final content = originalLine.trim();

          numberedLines.add('$leadingSpaces$nextNumber. $content');

          nextNumber++;
        }
      } else {
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

  static bool _isEmptyOrJustSpaces(String line) {
    return line.trim().isEmpty;
  }

  static int _lineIndexAtOffset(List<String> lines, int offset) {
    int currentOffset = 0;

    for (int i = 0; i < lines.length; i++) {
      if (offset <= currentOffset + lines[i].length) {
        return i;
      }

      currentOffset += lines[i].length + 1;
    }

    return lines.length - 1;
  }

  String getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }
}

String getMonthName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return months[month - 1];
}
