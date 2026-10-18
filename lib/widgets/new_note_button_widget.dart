// lib/widgets/new_note_button.dart

import 'package:flutter/material.dart';
import '../forms/push_note_form.dart';
import '../models/note.dart';

class NewNoteButton extends StatelessWidget {
  final double screenWidth;
  final Future<void> Function()? onRefresh;
  final String? defaultCategory;

  const NewNoteButton({
    super.key,
    required this.screenWidth,
    this.onRefresh,
    this.defaultCategory,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isLandscape = screenWidth > screenHeight;

    final double buttonWidth = isLandscape
        ? screenHeight * 0.70
        : screenWidth * 0.70;

    final double buttonHeight = isLandscape ? 32 : 40;
    final double fontSize = isLandscape ? 16 : 20;
    final double borderRadius = isLandscape ? 16 : 20;
    final double margin = isLandscape ? 8 : 10;

    return InkWell(
      onTap: () async {
        final category = defaultCategory ?? 'Personal';
        final isTodo = category == 'To-Do';

        final newNote = Note(
          title: '',
          content: '',
          createdAt: DateTime.now().toIso8601String(),
          category: category,
          isChecklist: isTodo,
          todoList: const [],
          isCompleted: false,
        );

        await pushNoteForm(context: context, note: newNote);

        await onRefresh?.call();
      },
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(margin),
        width: buttonWidth,
        height: buttonHeight,
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
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          'New Note',
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
