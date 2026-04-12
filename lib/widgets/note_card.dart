import 'package:flutter/material.dart';
import 'package:notibuku/models/note.dart';
import 'package:notibuku/services/sizefactor.dart';
import 'package:notibuku/models/date.dart';
// ✅ Add this import

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

  // ✅ NEW: Calculate pending tasks
  int _getPendingTasks() {
    if (note.isChecklist != true) return 0;
    return note.todoList.where((task) => !task.isCompleted).length;
  }

  int _getTotalTasks() {
    return note.todoList.length;
  }

  bool get _isTodoNote => note.isChecklist == true;

  @override
  Widget build(BuildContext context) {
    final noteColor = _hexToColor(note.color ?? '#FFFFFF');
    final titleColor = _hexToColor(note.titleTextColor ?? '#000000');
    final screenWidth = Func().screenWidth(context);
    final bool isSmall = screenWidth <= 322;
    final bool isMedium = screenWidth > 322 && screenWidth <= 700;

    double sizeFactor = getSizeFactor(context);
    final double contentfSize = sizeFactor * 0.02;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          // ✅ MAIN NOTE CARD
          Container(
            alignment: Alignment.topLeft,
            height: isSmall
                ? screenWidth * 0.32
                : isMedium
                ? screenWidth * 0.4
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
              children: [
                // Date circle
                Container(
                  height: isSmall
                      ? screenWidth * 0.1
                      : isMedium
                      ? screenWidth * 0.08
                      : screenWidth * 0.06,
                  width: isSmall
                      ? screenWidth * 0.1
                      : isMedium
                      ? screenWidth * 0.08
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
                              ? screenWidth * 0.05
                              : isMedium
                              ? screenWidth * 0.03
                              : screenWidth * 0.02,
                          color: titleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),

                // Title & Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ✅ TITLE - shows task count for todo notes
                      FittedBox(
                        child: Text(
                          note.title.isEmpty
                              ? 'Untitled'
                              : _isTodoNote
                              ? '${note.title} ($_getPendingTasks()/${_getTotalTasks()})' // ✅ Task badge in title
                              : note.title,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: isSmall
                                ? screenWidth * 0.06
                                : isMedium
                                ? screenWidth * 0.038
                                : screenWidth * 0.03,
                            fontWeight: FontWeight.w600,
                            fontFamily: note.titleFontFamily,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // ✅ CONTENT - shows task summary for todo notes
                      FittedBox(
                        child: Text(
                          _isTodoNote
                              ? '${_getPendingTasks()} pending • ${_getTotalTasks() - _getPendingTasks()} done' // ✅ Task summary
                              : note.content.split('\n').first.isEmpty
                              ? 'No content'
                              : note.content.split('\n').first,
                          style: TextStyle(
                            color: noteColor.computeLuminance() > 0.5
                                ? Colors.black87
                                : Colors.white70,
                            fontSize: isSmall
                                ? screenWidth * 0.04
                                : isMedium
                                ? screenWidth * 0.03
                                : screenWidth * 0.025,
                            fontFamily: note.contentFontFamily,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),

                // Time
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

          // - Top-right corner✅ 
          if (_isTodoNote)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha:  0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.checklist, size: 12, color: Colors.white),
                    SizedBox(width: 2),
                    Text(
                      '$_getPendingTasks()',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
