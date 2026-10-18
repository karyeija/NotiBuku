import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';

import 'package:notibuku/models/note.dart';
import 'package:notibuku/models/to_do_item.dart';
import 'package:notibuku/pickers/color_picker.dart';
import 'package:notibuku/pickers/font_picker.dart';
import 'package:notibuku/providers/to_do_providers.dart';
import 'package:notibuku/services/note_services.dart';
import 'package:notibuku/services/sizefactor.dart';
import 'package:notibuku/utils/helpers.dart';
import 'package:notibuku/widgets/fontslider.dart';
import 'package:notibuku/widgets/noteform/bottom_sheet_widget.dart';
import 'package:notibuku/widgets/noteform/content_widget.dart';
import 'package:notibuku/widgets/noteform/note_style_panel.dart';
import 'package:notibuku/widgets/noteform/title_widget.dart';
import 'package:notibuku/widgets/screenshot/screenshot_capture_button_widget.dart';
import 'package:notibuku/widgets/screenshot_dialog_widget.dart';

class NoteFormWidget extends ConsumerStatefulWidget {
  final Note? note;

  const NoteFormWidget({super.key, this.note});

  @override
  ConsumerState<NoteFormWidget> createState() => _NoteFormWidgetState();
}

class _NoteFormWidgetState extends ConsumerState<NoteFormWidget> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final ScreenshotController screenshotController = ScreenshotController();

  String? selectedCategory;
  String title = '';
  String content = '';

  Color noteColor = Colors.white;
  Color titleColor = Colors.black87;
  Color contentColor = Colors.black87;

  bool _isCapturing = false;
  bool _isSaving = false;
  bool isEditing = false;
  bool _isChecklistMode = false;

  List<TodoItem> _todoList = [];

  late FocusNode _titleFocusNode;
  late FocusNode _contentFocusNode;
  late ValueNotifier<bool> _numberingNotifier;

  String titleFontFamily = 'Roboto';
  String contentFontFamily = 'Roboto';

  double titleFontSize = 20.0;
  double contentFontSize = 16.0;

  @override
  void initState() {
    super.initState();

    title = widget.note?.title ?? '';
    content = widget.note?.content ?? '';

    noteColor = _hexToColor(widget.note?.color ?? '#FFFFFF');
    titleColor = _hexToColor(widget.note?.titleTextColor ?? '#000000');
    contentColor = _hexToColor(widget.note?.contentTextColor ?? '#000000');

    selectedCategory = widget.note?.category ?? 'Personal';

    // Existing checklist notes retain their identity.
    // New notes opened in the To-Do category start as checklists.
    _isChecklistMode =
        widget.note?.isChecklist == true || selectedCategory == 'To-Do';

    if (_isChecklistMode && widget.note != null) {
      _todoList = List<TodoItem>.from(widget.note!.todoList);
    }

    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();

    _titleFocusNode.addListener(_handleFocusChange);
    _contentFocusNode.addListener(_handleFocusChange);

    _titleController.text = title;
    _contentController.text = content;

    _titleController.addListener(_updateSaveButtonEnablement);
    _contentController.addListener(_updateSaveButtonEnablement);

    _numberingNotifier = ValueNotifier<bool>(false);

    titleFontFamily = widget.note?.titleFontFamily ?? 'Roboto';
    contentFontFamily = widget.note?.contentFontFamily ?? 'Roboto';

    titleFontSize = widget.note?.titleFontSize ?? 20.0;
    contentFontSize = widget.note?.contentFontSize ?? 16.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref.read(titleFontSizeProvider.notifier).setFontSize(titleFontSize);
      ref.read(contentFontSizeProvider.notifier).setFontSize(contentFontSize);
    });

    debugPrint('Note title: ${widget.note?.title}');
    debugPrint('Note category: ${widget.note?.category}');
    debugPrint('Is checklist: ${widget.note?.isChecklist}');
    debugPrint('Task count: ${widget.note?.todoList.length}');
    debugPrint(
      'Loaded tasks: ${widget.note?.todoList.map((t) => t.text).toList()}',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await DatabaseService.debugTodoNote('You');
    });
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');

    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    return Color(int.parse(hex, radix: 16));
  }

  String _colorToHex(Color color) =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  void _handleFocusChange() {
    if (!mounted) return;

    setState(() {
      isEditing = _titleFocusNode.hasFocus || _contentFocusNode.hasFocus;
    });
  }

  Future<void> _showTitleFontPicker() async {
    final selectedFont = await showFontPickerDialog(context);

    if (selectedFont != null && mounted) {
      setState(() => titleFontFamily = selectedFont);
    }
  }

  Future<void> _showContentFontPicker() async {
    final selectedFont = await showFontPickerDialog(context);

    if (selectedFont != null && mounted) {
      setState(() => contentFontFamily = selectedFont);
    }
  }

  Future<void> _showTitleColorPicker() async {
    final selectedColor = await showNoteColorPicker(context);

    if (selectedColor != null && mounted) {
      setState(() => titleColor = selectedColor);
    }
  }

  Future<void> _showContentColorPicker() async {
    final selectedColor = await showNoteColorPicker(context);

    if (selectedColor != null && mounted) {
      setState(() => contentColor = selectedColor);
    }
  }

  Future<void> _showColorPicker() async {
    final selectedColor = await showNoteColorPicker(context);

    if (selectedColor != null && mounted) {
      setState(() => noteColor = selectedColor);
    }
  }

  bool _isNoteChanged() {
    final prev = widget.note;

    if (prev == null) return true;

    return prev.title != _titleController.text ||
        prev.content != _contentController.text ||
        prev.color != _colorToHex(noteColor) ||
        prev.titleTextColor != _colorToHex(titleColor) ||
        prev.contentTextColor != _colorToHex(contentColor) ||
        prev.titleFontFamily != titleFontFamily ||
        prev.contentFontFamily != contentFontFamily ||
        prev.titleFontSize != titleFontSize ||
        prev.contentFontSize != contentFontSize ||
        prev.isChecklist != _isChecklistMode ||
        prev.category != (selectedCategory ?? 'Personal');
  }

  bool _isSaveButtonEnabled() {
    if (widget.note?.id == null) return true;

    return _isNoteChanged() || _hasTodoChanges();
  }

  void _updateSaveButtonEnablement() {
    title = _titleController.text;
    content = _contentController.text;

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() {
      _isSaving = true;
      title = _titleController.text;
      content = _contentController.text;
    });

    try {
      debugPrint('--- SAVING CHECKLIST ---');
      debugPrint('Title: ${_titleController.text}');
      debugPrint('Checklist mode: $_isChecklistMode');
      debugPrint('Tasks in memory: ${_todoList.length}');
      debugPrint('Task values: ${_todoList.map((task) => task.text).toList()}');
      final isNew = widget.note?.id == null;

      final note = Note(
        id: widget.note?.id,
        title: _titleController.text,
        content: _contentController.text,
        color: _colorToHex(noteColor),
        titleTextColor: _colorToHex(titleColor),
        contentTextColor: _colorToHex(contentColor),
        titleFontFamily: titleFontFamily,
        contentFontFamily: contentFontFamily,
        category: selectedCategory ?? widget.note?.category ?? 'Personal',
        createdAt: isNew
            ? DateTime.now().toIso8601String()
            : widget.note!.createdAt,
        titleFontSize: titleFontSize,
        contentFontSize: contentFontSize,
        isChecklist: _isChecklistMode,
        todoList: List<TodoItem>.from(_todoList),
        isCompleted: widget.note?.isCompleted ?? false,
      );

      late final Note savedNote;

      if (isNew) {
        final newId = await DatabaseService.addNote(note);
        if (!mounted) return;

        savedNote = note.copyWith(id: newId);
        ref.read(todoNotesProvider.notifier).addTodoNote(savedNote);
      } else {
        await DatabaseService.updateNote(note);
        if (!mounted) return;

        savedNote = note;
        ref.read(todoNotesProvider.notifier).updateTodoNote(savedNote);
      }

      if (!mounted) return;

      // Show feedback before closing the form.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isNew ? 'Note created!' : 'Note updated!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop<Note>(savedNote);
    } catch (e, stackTrace) {
      debugPrint('Save failed: $e');
      debugPrintStack(label: 'Save stack trace', stackTrace: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _updateTodoCompletion(int index, bool isCompleted) async {
    if (index < 0 || index >= _todoList.length) return;

    final item = _todoList[index];

    setState(() {
      _todoList[index] = TodoItem(
        id: item.id,
        text: item.text,
        isCompleted: isCompleted,
      );

      isEditing = true;
    });

    final noteId = widget.note?.id;

    // New notes are persisted when Save is pressed.
    if (noteId == null) return;

    final updatedNote = Note(
      id: noteId,
      title: _titleController.text,
      content: _contentController.text,
      color: _colorToHex(noteColor),
      titleTextColor: _colorToHex(titleColor),
      contentTextColor: _colorToHex(contentColor),
      titleFontFamily: titleFontFamily,
      contentFontFamily: contentFontFamily,
      category: selectedCategory ?? widget.note?.category ?? 'Personal',
      createdAt: widget.note!.createdAt,
      titleFontSize: titleFontSize,
      contentFontSize: contentFontSize,
      isChecklist: _isChecklistMode,
      isCompleted: widget.note?.isCompleted ?? false,
      todoList: List<TodoItem>.from(_todoList),
    );

    try {
      await DatabaseService.updateNote(updatedNote);

      if (!mounted) return;

      ref.read(todoNotesProvider.notifier).updateTodoNote(updatedNote);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save task progress: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildChecklistView() {
    return ListView.builder(
      itemCount: _todoList.length,
      padding: const EdgeInsets.only(bottom: 100),
      itemBuilder: (context, index) {
        final item = _todoList[index];

        return ListTile(
          key: ValueKey(item.id),
          titleAlignment: ListTileTitleAlignment.center,

          dense: true,
          leading: Checkbox(
            value: item.isCompleted,
            onChanged: widget.note?.id == null
                ? null
                : (value) {
                    _updateTodoCompletion(index, value ?? false);
                  },
          ),
          title: TextFormField(
            key: ValueKey('task-${item.id}'),
            initialValue: item.text,
            decoration: const InputDecoration(
              hintText: 'Enter task',
              border: InputBorder.none,
              isDense: true,
            ),
            maxLines: 2,
            style: const TextStyle(fontSize: 14),
            onChanged: (newText) {
              _todoList[index] = TodoItem(
                id: item.id,
                text: newText,
                isCompleted: item.isCompleted,
              );
            },
            onSaved: (value) {
              _todoList[index] = TodoItem(
                id: item.id,
                text: value ?? '',
                isCompleted: item.isCompleted,
              );
            },
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              setState(() {
                _todoList.removeAt(index);
                isEditing = true;
              });
            },
          ),
        );
      },
    );
  }

  bool _hasTodoChanges() {
    final original = widget.note?.todoList ?? [];

    if (original.length != _todoList.length) return true;

    for (var i = 0; i < original.length; i++) {
      final oldItem = original[i];
      final newItem = _todoList[i];

      if (oldItem.id != newItem.id ||
          oldItem.text.trim() != newItem.text.trim() ||
          oldItem.isCompleted != newItem.isCompleted) {
        return true;
      }
    }

    return false;
  }

  void _checkTodoChanges() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _captureNoteContent() async {
    if (_isCapturing) return;

    setState(() => _isCapturing = true);

    final screenWidth = MediaQuery.of(context).size.width;

    final noteContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
          child: Text(
            content.isEmpty ? 'Your content here' : content,
            textAlign: TextAlign.start,
            maxLines: null,
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontFamily: contentFontFamily,
              color: contentColor,
              fontSize: contentFontSize,
              height: 1.5,
            ),
          ),
        ),
      ],
    );

    final noteWidget = Material(
      color: noteColor,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: IntrinsicHeight(child: IntrinsicWidth(child: noteContent)),
      ),
    );

    try {
      final image = await screenshotController.captureFromWidget(
        noteWidget,
        delay: const Duration(milliseconds: 1),
        pixelRatio: 8.0,
      );

      if (mounted) {
        _showScreenshotDialog(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  void _showScreenshotDialog(Uint8List image) {
    showDialog(
      context: context,
      builder: (dialogContext) => ScreenshotDialog(
        image: image,
        parentContext: context,
        parentMounted: mounted,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateSaveButtonEnablement);
    _contentController.removeListener(_updateSaveButtonEnablement);

    _titleFocusNode.removeListener(_handleFocusChange);
    _contentFocusNode.removeListener(_handleFocusChange);

    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _numberingNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleSize = ref.watch(titleFontSizeProvider);
    final contentSize = ref.watch(contentFontSizeProvider);

    Func().screenWidth(context);

    if (titleFontSize != titleSize) titleFontSize = titleSize;
    if (contentFontSize != contentSize) contentFontSize = contentSize;

    final bool showChecklist = _isChecklistMode;

    return Scaffold(
      backgroundColor: noteColor,
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                (widget.note?.content ?? '').isEmpty
                    ? 'New $selectedCategory Note'
                    : 'Edit Note',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _numberingNotifier,
              builder: (context, value, child) {
                return IconButton(
                  icon: Icon(
                    value
                        ? Icons.format_list_numbered
                        : Icons.format_list_bulleted,
                    color: value ? Colors.amber : Colors.white70,
                  ),
                  onPressed: () {
                    final selection = _contentController.selection;

                    if (selection.start == selection.end) return;

                    _numberingNotifier.value = !value;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final newText = value
                          ? AutoNumberListFormatter.removeNumberingFromLines(
                              _contentController.text,
                              selection.start,
                              selection.end,
                            )
                          : AutoNumberListFormatter.numberSelectedLines(
                              _contentController.text,
                              selection.start,
                              selection.end,
                            );

                      _contentController.value = TextEditingValue(
                        text: newText,
                        selection: selection,
                      );

                      _checkTodoChanges();
                    });
                  },
                );
              },
            ),
            IconButton(
              icon: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: noteColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.palette,
                  size: 16,
                  color: noteColor.computeLuminance() > 0.5
                      ? Colors.black87
                      : Colors.white,
                ),
              ),
              onPressed: _showColorPicker,
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
      bottomSheet: !isEditing
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NoteStylePanel(
                  numberingNotifier: _numberingNotifier,
                  onShowTitleFontPicker: _showTitleFontPicker,
                  onShowContentFontPicker: _showContentFontPicker,
                  onShowTitleColorPicker: _showTitleColorPicker,
                  onShowContentColorPicker: _showContentColorPicker,
                  titleFontFamily: titleFontFamily,
                  contentFontFamily: contentFontFamily,
                  titleColor: titleColor,
                  contentColor: contentColor,
                  titleFontSize: titleFontSize,
                  contentFontSize: contentFontSize,
                ),
                NoteBottomSheet(
                  onCancel: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  onSave: _save,
                  onAddTask: () {
                    setState(() {
                      _isChecklistMode = true;

                      _todoList.add(
                        TodoItem(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          text: '',
                          isCompleted: false,
                        ),
                      );

                      isEditing = true;
                    });
                  },
                  isSaving: _isSaving,
                  isSaveButtonEnabled: _isSaveButtonEnabled(),
                  isChecklistMode: _isChecklistMode,
                ),
              ],
            ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  NoteTitleField(
                    controller: _titleController,
                    focusNode: _titleFocusNode,
                    fontFamily: titleFontFamily,
                    textColor: titleColor,
                    fontSize: titleFontSize,
                  ),

                  if (showChecklist) ...[
                    // To-Do notes: show tasks only, not the content field.
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (!isEditing) {
                            setState(() => isEditing = true);
                          }
                        },
                        child: _buildChecklistView(),
                      ),
                    ),
                  ] else ...[
                    // Regular notes: show the content field.
                    Expanded(
                      child: NoteContentField(
                        controller: _contentController,
                        focusNode: _contentFocusNode,
                        fontFamily: contentFontFamily,
                        textColor: contentColor,
                        fontSize: contentFontSize,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 100,
            child: ScreenshotCaptureButton(
              isCapturing: _isCapturing,
              onCapture: _captureNoteContent,
              iconSizeFactor: 0.09,
              enabledColor: Colors.black87,
              disabledColor: Colors.orange,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
