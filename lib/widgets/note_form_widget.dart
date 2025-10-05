import 'package:flutter/material.dart';
import 'package:notibuku/models/note.dart';
import 'package:notibuku/services/note_services.dart';
import 'package:notibuku/services/sizefactor.dart';

class NoteFormWidget extends StatefulWidget {
  final Note? note;
  const NoteFormWidget({super.key, this.note});

  @override
  State<NoteFormWidget> createState() => _NoteFormWidgetState();
}

class _NoteFormWidgetState extends State<NoteFormWidget> {
  final _formKey = GlobalKey<FormState>();
  String title = '', content = '';

  late FocusNode _titleFocusNode;
  late FocusNode _contentFocusNode;

  bool isEditing = false;

  @override
  void initState() {
    super.initState();

    title = widget.note?.title ?? '';
    content = widget.note?.content ?? '';

    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();

    _titleFocusNode.addListener(_handleFocusChange);
    _contentFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      isEditing = _titleFocusNode.hasFocus || _contentFocusNode.hasFocus;
    });
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final note = Note(
        id: widget.note?.id,
        title: title,
        content: content,
        createdAt: widget.note?.createdAt ?? DateTime.now().toIso8601String(),
      );
      try {
        if (widget.note == null) {
          await DatabaseService.addNote(note);
        } else {
          if (note.id == null) throw Exception('Update failed: id is null');
          await DatabaseService.updateNote(note);
        }
        // ignore: use_build_context_synchronously
        if (context.mounted) Navigator.of(context).pop(true);
      } catch (e) {
        debugPrint('Database save error: $e');
        // Optionally show error feedback to user here
      }
    }
  }

  @override
  void dispose() {
    _titleFocusNode.removeListener(_handleFocusChange);
    _contentFocusNode.removeListener(_handleFocusChange);
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  // ... your _save method unchanged ...

  @override
  Widget build(BuildContext context) {
    double sizeFactor = getSizeFactor(context);
    final double titlefSize = sizeFactor * 0.025;
    final double contentfSize = sizeFactor * 0.02;
    return Scaffold(
      appBar: AppBar(
        actions: isEditing
            ? [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: sizeFactor * 0.1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _save,
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            : [],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Form(
          key: _formKey,
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: sizeFactor * 0.05,
                  child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    focusNode: _titleFocusNode,
                    initialValue: title,
                    decoration: const InputDecoration(hintText: 'Title'),
                    style: TextStyle(
                      fontSize: titlefSize,
                      fontWeight: FontWeight.bold,
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Required" : null,
                    onSaved: (v) => title = v ?? '',
                    maxLines: 1,
                    scrollPhysics: const AlwaysScrollableScrollPhysics(),
                    keyboardType: TextInputType.text,
                    textAlignVertical: TextAlignVertical.center,
                  ),
                ),
                Expanded(
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 8.0),
                        child: TextFormField(
                          focusNode: _contentFocusNode,
                          style: TextStyle(fontSize: contentfSize),
                          textCapitalization: TextCapitalization.sentences,
                          initialValue: content,

                          decoration: const InputDecoration(
                            hintText: 'Content',
                            border: InputBorder.none,
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? "Required" : null,
                          onSaved: (v) => content = v ?? '',
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          // maxLines: (sizeFactor * 0.9).toInt(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
