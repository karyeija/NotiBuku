// lib/widgets/new_note_button.dart
import 'package:flutter/material.dart';
import '../forms/push_note_form.dart';
import '../models/note.dart';

class NewNoteButton extends StatelessWidget {
  final double screenWidth;
  final VoidCallback? onRefresh; // ← loadNotes() callback
  final String? defaultCategory; // ← Smart category

  const NewNoteButton({
    super.key,
    required this.screenWidth,
    this.onRefresh,
    this.defaultCategory,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await pushNoteForm(
          context: context,
          note: Note(
            title: '',
            content: '',
            createdAt: DateTime.now().toIso8601String(),
            category: defaultCategory ?? 'Personal',
          ),
        );
        onRefresh?.call(); // Refresh parent list
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        width: screenWidth * 0.7,
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 153, 123, 16),
              Color.fromARGB(255, 94, 3, 110),
              Colors.purple,
              Color.fromARGB(255, 241, 153, 147),
              Colors.blue,
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'New Note',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
