import 'package:flutter/material.dart';
import 'package:notibuku/models/note.dart';
import 'package:notibuku/widgets/note_form_widget.dart';

class DetailsPage extends StatelessWidget {
  final Note? note;

  const DetailsPage({super.key, this.note});

  @override
  Widget build(BuildContext context) {
    // final title = note == null ? 'Add Note' : note?.title;

    return Scaffold(
      // appBar: AppBar(title: Text(note!.title)),
      body: NoteFormWidget(note: note),
    );
  }
}
