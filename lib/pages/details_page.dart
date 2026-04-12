import 'package:flutter/material.dart';
import 'package:notibuku/forms/note_form_widget.dart';
import 'package:notibuku/models/note.dart';

class DetailsPage extends StatelessWidget {
  final Note? note;
  const DetailsPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return NoteFormWidget(note: note);
  }
}
