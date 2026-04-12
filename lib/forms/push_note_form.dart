// lib/forms/push_note_form.dart
import 'package:flutter/material.dart';
import 'package:notibuku/forms/note_form_widget.dart';
import '../../models/note.dart';

Future<void> pushNoteForm({required BuildContext context, Note? note}) async {
  await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => NoteFormWidget(note: note),
      fullscreenDialog: true,
    ),
  );
  // No ref.invalidate needed - parent handles refresh
}
