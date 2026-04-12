import 'package:flutter/material.dart';
import 'package:notibuku/models/note.dart';
import 'package:notibuku/widgets/note_card.dart';
import 'package:notibuku/widgets/todo_notecard.dart';

class DismissibleNoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? cardHeight;
  final BuildContext parentContext;

  const DismissibleNoteCard({
    super.key,
    required this.note,
    required this.onDelete,
    required this.parentContext,
    this.onTap,
    this.onLongPress,
    this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(note.id.toString()),
      confirmDismiss: (direction) => _confirmDelete(context),
      onDismissed: (direction) => onDelete(),
      background: _buildDeleteBackground(),
      child: _buildNoteCard(),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  Widget _buildNoteCard() {
    final isTodo = note.category == 'To-Do';

    if (isTodo) {
      return TodoNoteCard(
        note: note,
        onTap: onTap ?? () {},
        onLongPress: onLongPress,
      );
    }

    return NoteCard(
      note: note,
      onTap: onTap ?? () {},
      onLongPress: onLongPress,
    );
  }
}
