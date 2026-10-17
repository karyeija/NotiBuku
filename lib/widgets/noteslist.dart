import 'package:flutter/material.dart';
import 'package:notibuku/models/note.dart';
import 'package:notibuku/widgets/notes/grouped_notes_list_widget.dart';
import 'package:notibuku/widgets/screenshot/todo_summary.dart';

class NotiBukuNotesList extends StatelessWidget {
  final Map<String, List<Note>> displayNotes;

  final double sizeFactor;
  final double titlefSize;
  final bool isSmall;
  final bool isMedium;
  final double screenWidth;
  final bool hasActiveFilter;
  final bool isLandscape;

  final String searchText;
  final DateTime? selectedDate;
  final TextEditingController searchController;

  final VoidCallback applyFilters;
  final VoidCallback clearDateOnly;

  final Future<void> Function(int id) deleteNote;
  final void Function(Note note) showNoteDialog;
  final void Function(Note note) toggleTodoComplete;
  final Future<void> Function() loadNotes;

  final String Function(int month) getMonthName;

  const NotiBukuNotesList({
    super.key,
    required this.displayNotes,
    required this.sizeFactor,
    required this.titlefSize,
    required this.isSmall,
    required this.isMedium,
    required this.screenWidth,
    required this.hasActiveFilter,
    required this.isLandscape,
    required this.searchText,
    required this.selectedDate,
    required this.searchController,
    required this.applyFilters,
    required this.clearDateOnly,
    required this.deleteNote,
    required this.showNoteDialog,
    required this.toggleTodoComplete,
    required this.loadNotes,
    required this.getMonthName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (hasActiveFilter)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 16 : 8,
              vertical: isLandscape ? 4 : 8,
            ),
            child: Wrap(
              spacing: isLandscape ? 6 : 8,
              runSpacing: isLandscape ? 4 : 8,
              children: [
                if (searchText.isNotEmpty)
                  Chip(
                    label: Text(
                      'Search: $searchText',
                      style: TextStyle(fontSize: isLandscape ? 12 : 14),
                    ),
                    visualDensity: isLandscape
                        ? const VisualDensity(horizontal: -2, vertical: -2)
                        : VisualDensity.standard,
                    onDeleted: () {
                      searchController.clear();
                      applyFilters();
                    },
                    deleteIcon: Icon(Icons.close, size: isLandscape ? 16 : 18),
                  ),
                if (selectedDate != null)
                  Chip(
                    label: Text(
                      '${selectedDate!.day} '
                      '${getMonthName(selectedDate!.month)}',
                      style: TextStyle(fontSize: isLandscape ? 12 : 14),
                    ),
                    visualDensity: isLandscape
                        ? const VisualDensity(horizontal: -2, vertical: -2)
                        : VisualDensity.standard,
                    onDeleted: clearDateOnly,
                    deleteIcon: Icon(Icons.close, size: isLandscape ? 16 : 18),
                  ),
              ],
            ),
          ),

        GroupedNotesList(
          displayNotes: displayNotes,

          // Dismissible card deletion uses the note ID.
          onDelete: deleteNote,

          onTapRegularNote: showNoteDialog,

          onTapTodoNote: (note) async {
            final result = await showDialog<Note>(
              context: context,
              builder: (dialogContext) {
                return TodoSummaryDialog(note: note);
              },
            );

            if (result != null) {
              await loadNotes();
            }
          },

          onToggleComplete: toggleTodoComplete,

          // Long-press deletion uses the same ID-based callback.
          onLongPress: (note) {
            if (note.id != null) {
              deleteNote(note.id!);
            }
          },

          screenWidth: screenWidth,
          sizeFactor: sizeFactor,
          titlefSize: titlefSize,
          isSmall: isSmall,
          isMedium: isMedium,
          getMonthName: getMonthName,
          isLandscape: isLandscape,
        ),
      ],
    );
  }
}
