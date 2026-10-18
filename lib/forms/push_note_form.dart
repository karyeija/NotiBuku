import 'package:flutter/material.dart';
import 'package:notibuku/forms/note_form_widget.dart';
import 'package:notibuku/models/note.dart';

Future<Note?> pushNoteForm({required BuildContext context, Note? note}) async {
  return Navigator.of(context).push<Note>(
    MaterialPageRoute<Note>(
      builder: (_) => NoteFormWidget(note: note),
      fullscreenDialog: true,
    ),
  );
}
