// lib/widgets/grouped_notes_list.dart
import 'package:flutter/material.dart';
import 'package:notibuku/models/note.dart';
import 'package:notibuku/widgets/dismissible_note_card_widget.dart';

class GroupedNotesList extends StatelessWidget {
  final Map<String, List<Note>> displayNotes;
  final void Function(int) onDelete;
  final void Function(Note) onTapRegularNote; // ✅ For regular notes
  final void Function(Note) onTapTodoNote; // ✅ For todo notes
  final void Function(Note)? onToggleComplete;
  final void Function(Note)? onLongPress;
  final bool isSmall;
  final bool isMedium;
  final double screenWidth;
  final double sizeFactor;
  final double titlefSize;
  final String Function(int) getMonthName;

  const GroupedNotesList({
    super.key,
    required this.displayNotes,
    required this.onDelete,
    required this.onTapRegularNote, // ✅ Split callbacks
    required this.onTapTodoNote, // ✅ Split callbacks
    required this.screenWidth,
    required this.sizeFactor,
    required this.titlefSize,
    required this.isSmall,
    required this.isMedium,
    required this.getMonthName,
    this.onToggleComplete,
    this.onLongPress,
  });

  String _formatDay(DateTime dayDate) {
    final now = DateTime.now();
    return dayDate.day == now.day &&
            dayDate.month == now.month &&
            dayDate.year == now.year
        ? 'Today'
        : '${dayDate.day} ${getMonthName(dayDate.month)} ${dayDate.year}';
  }

  // ✅ NEW: Smart tap handler
  void _handleNoteTap(Note note, BuildContext context) {
    final bool isTodoNote =
        note.isChecklist == true && note.todoList.isNotEmpty;

    if (isTodoNote) {
      onTapTodoNote(note);
    } else {
      onTapRegularNote(note);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: displayNotes.length,
        itemBuilder: (context, groupIndex) {
          final dayKeys = displayNotes.keys.toList();
          final dayKey = dayKeys[groupIndex];
          final dayNotes = displayNotes[dayKey]!;
          final dayDate = DateTime.parse(dayKey);
          final formattedDay = _formatDay(dayDate);

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ExpansionTile(
              expandedAlignment: Alignment.centerLeft,
              initiallyExpanded: false,
              leading: CircleAvatar(
                radius: sizeFactor * 0.03,
                backgroundColor: const Color.fromARGB(255, 244, 235, 220),
                child: Text(
                  dayNotes.length.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: titlefSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[900],
                  ),
                ),
              ),
              title: Center(
                child: Text(
                  formattedDay,
                  style: TextStyle(
                    fontSize: 18,
                    color: const Color.fromARGB(255, 87, 5, 102),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              backgroundColor: const Color.fromARGB(255, 244, 235, 220),
              collapsedBackgroundColor: const Color.fromARGB(0, 58, 11, 11),
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                side: const BorderSide(
                  color: Color.fromARGB(255, 1, 72, 45),
                  width: 1,
                ),
              ),
              children: dayNotes.map((note) {
                final cardHeight = isSmall
                    ? screenWidth * 0.2
                    : isMedium
                    ? screenWidth * 0.14
                    : screenWidth * 0.1;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: SizedBox(
                    height: cardHeight,
                    child: DismissibleNoteCard(
                      note: note,
                      onDelete: () => onDelete(note.id!),
                      onTap: () => _handleNoteTap(note, context),
                      onLongPress: onLongPress != null
                          ? () => onLongPress!(note)
                          : null,
                      parentContext: context,
                      cardHeight: cardHeight,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
