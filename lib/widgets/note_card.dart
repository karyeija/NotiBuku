import 'package:flutter/material.dart';
import 'package:notibuku/models/note.dart';
import 'package:notibuku/services/sizefactor.dart';
import 'package:notibuku/models/date.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const NoteCard({super.key, required this.note, this.onTap, this.onLongPress});

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final noteColor = _hexToColor(note.color ?? '#FFFFFF');
    final titleColor = _hexToColor(note.titleTextColor ?? '#000000');
    final screenWidth = Func().screenWidth(context);
    final bool isSmall = screenWidth <= 322;
    final bool isMedium = screenWidth > 322 && screenWidth <= 700;

    // final contentColor = _hexToColor(note.contentTextColor ?? '#000000');

    double sizeFactor = getSizeFactor(context);
    final double contentfSize = sizeFactor * 0.02;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        alignment: Alignment.topLeft,
        height: isSmall
            ? screenWidth *
                  0.32 // Reduced sizes
            : isMedium
            ? screenWidth *
                  0.4 // Reduced sizes
            : screenWidth * 0.15,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: noteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.le,
          children: [
            // Date circle
            Container(
              height: isSmall
                  ? screenWidth *
                        0.1 // Reduced sizes
                  : isMedium
                  ? screenWidth *
                        0.08 // Reduced sizes
                  : screenWidth * 0.06,
              width: isSmall
                  ? screenWidth *
                        0.1 // Reduced sizes
                  : isMedium
                  ? screenWidth *
                        0.08 // Reduced sizes
                  : screenWidth * 0.16,
              decoration: BoxDecoration(
                color: noteColor.computeLuminance() > 0.5
                    ? const Color.fromARGB(
                        255,
                        217,
                        228,
                        220,
                      ).withValues(alpha: .9)
                    : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FittedBox(
                  child: Text(
                    FormatDate.dayOrToday(note.createdAt),
                    style: TextStyle(
                      fontSize: isSmall
                          ? screenWidth *
                                0.05 // Reduced sizes
                          : isMedium
                          ? screenWidth *
                                0.03 // Reduced sizes
                          : screenWidth * 0.02,
                      color: titleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),

            // Title & Content with FONTFAMILY!
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🔥 TITLE with custom fontFamily
                  FittedBox(
                    child: Text(
                      note.title.isEmpty ? 'Untitled' : note.title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: isSmall
                            ? screenWidth *
                                  0.06 // Reduced sizes
                            : isMedium
                            ? screenWidth *
                                  0.038 // Reduced sizes
                            : screenWidth * 0.03,
                        fontWeight: FontWeight.w600,
                        fontFamily: note.titleFontFamily, //  Inherits!
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 🔥 CONTENT with custom fontFamily
                  FittedBox(
                    child: Text(
                      note.content.split('\n').first.isEmpty
                          ? 'No content'
                          : note.content.split('\n').first,
                      style: TextStyle(
                        color: noteColor.computeLuminance() > 0.5
                            ? Colors.black87
                            : Colors.white70,
                        fontSize: isSmall
                            ? screenWidth *
                                  0.04 // Reduced sizes
                            : isMedium
                            ? screenWidth *
                                  0.03 // Reduced sizes
                            : screenWidth * 0.025,
                        fontFamily: note.contentFontFamily, //  Inherits!
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),

            // Time (keeps Technology font)
            Text(
              FormatDate.hour(note.createdAt),
              style: TextStyle(
                fontSize: contentfSize * 0.9,
                fontFamily: 'Technology',
                fontWeight: FontWeight.w500,
                color: noteColor.computeLuminance() > 0.5
                    ? Colors.black87
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
