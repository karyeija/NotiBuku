import 'package:flutter/material.dart';
import 'package:notibuku/models/note.dart';
import 'package:notibuku/services/sizefactor.dart';
import 'package:notibuku/models/date.dart';

class TodoNoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const TodoNoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onLongPress,
  });

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  bool get _isTodoNote => note.isChecklist == true;

  @override
  Widget build(BuildContext context) {
    final noteColor = _hexToColor(note.color ?? '#FFFFFF');
    final titleColor = _hexToColor(note.titleTextColor ?? '#000000');
    final screenWidth = Func().screenWidth(context);

    final bool isSmall = screenWidth <= 322;
    final bool isMedium = screenWidth > 322 && screenWidth <= 700;

    final double sizeFactor = getSizeFactor(context);
    final double contentfSize = sizeFactor * 0.02;

    final todos = note.todoList;

    final int pendingTasks = todos.where((t) => !t.isCompleted).length;

    final int totalTasks = todos.length;

    final int completedTasks = totalTasks - pendingTasks;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          /// ================= CARD =================
          Container(
            alignment: Alignment.topLeft,
            height: isSmall
                ? screenWidth * 0.32
                : isMedium
                ? screenWidth * 0.4
                : screenWidth * 0.15,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: noteColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                /// 📅 DATE CIRCLE
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
                        ? const Color(0xFFD9E4DC).withValues(alpha: 0.9)
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

                const SizedBox(width: 8),

                /// 📝 TEXT CONTENT
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title.isEmpty ? 'Untitled' : note.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                      ),

                      const SizedBox(height: 4),

                      Text(
                        _isTodoNote
                            ? '$pendingTasks pending • $completedTasks done'
                            : (note.content.isEmpty
                                  ? 'No content'
                                  : note.content.split('\n').first),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: noteColor.computeLuminance() > 0.5
                              ? Colors.black87
                              : Colors.white70,
                          fontSize: isSmall
                              ? screenWidth * 0.04
                              : isMedium
                              ? screenWidth * 0.03
                              : screenWidth * 0.025,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                /// ⏰ TIME
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

          if (_isTodoNote)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$pendingTasks',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
