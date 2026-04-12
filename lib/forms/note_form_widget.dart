import 'package:notibuku/models/to_do_item.dart';
import 'package:notibuku/providers/to_do_providers.dart';
import 'package:notibuku/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notibuku/widgets/noteform/bottom_sheet_widget.dart';
import 'package:notibuku/widgets/noteform/content_widget.dart';
import 'package:notibuku/widgets/noteform/note_style_panel.dart';
import 'package:notibuku/widgets/noteform/title_widget.dart';
import 'package:notibuku/widgets/screenshot/screenshot_capture_button_widget.dart';
import 'package:notibuku/widgets/screenshot_dialog_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:notibuku/models/note.dart';
import 'package:notibuku/pickers/color_picker.dart';
import 'package:notibuku/pickers/font_picker.dart';
import 'package:notibuku/services/note_services.dart';
import 'package:notibuku/services/sizefactor.dart';
import 'package:notibuku/widgets/fontslider.dart';

class NoteFormWidget extends ConsumerStatefulWidget {
  final Note? note;

  const NoteFormWidget({super.key, this.note});

  @override
  ConsumerState<NoteFormWidget> createState() => _NoteFormWidgetState();
}

class _NoteFormWidgetState extends ConsumerState<NoteFormWidget> {
  final TextEditingController _titleController = TextEditingController(); // NEW
  final TextEditingController _contentController = TextEditingController();
  String? selectedCategory;
  bool _isCapturing = false; // Track capture state
  final _formKey = GlobalKey<FormState>();
  String title = '', content = '';
  Color noteColor = Colors.white;
  Color titleColor = Colors.black87;
  Color contentColor = Colors.black87;
  bool _isSaving = false;
  bool isEditing = false;
  late FocusNode _titleFocusNode;
  late FocusNode _contentFocusNode;
  late ValueNotifier<bool> _numberingNotifier;
  String titleFontFamily = 'Roboto';
  String contentFontFamily = 'Roboto';
  double titleFontSize = 20.0;
  double contentFontSize = 16.0;
  ScreenshotController screenshotController = ScreenshotController();

  // ✅ NEW: checklist portion
  bool _isChecklistMode = false;
  List<TodoItem> _todoList = [];

  @override
  void initState() {
    super.initState();

    title = widget.note?.title ?? '';
    content = widget.note?.content ?? '';
    noteColor = _hexToColor(widget.note?.color ?? '#FFFFFF');
    titleColor = _hexToColor(widget.note?.titleTextColor ?? '#000000');
    contentColor = _hexToColor(widget.note?.contentTextColor ?? '#000000');
    selectedCategory = widget.note?.category ?? 'Personal';

    // ✅ Load checklist state if this note has a todoList
    if (widget.note?.isChecklist == true) {
      _isChecklistMode = true;
      _todoList = List<TodoItem>.from(widget.note!.todoList);
    }

    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();

    _titleFocusNode.addListener(_handleFocusChange);
    _contentFocusNode.addListener(_handleFocusChange);

    _titleController.text = title; // ✅ controller gets initial title
    _contentController.text = content; // ✅ controller gets initial content

    _titleController.addListener(
      _updateSaveButtonEnablement,
    ); // listen to title
    _contentController.addListener(
      _updateSaveButtonEnablement,
    ); // listen to content

    _numberingNotifier = ValueNotifier(false);

    titleFontFamily = widget.note?.titleFontFamily ?? 'Roboto';
    contentFontFamily = widget.note?.contentFontFamily ?? 'Roboto';
    titleFontSize = widget.note?.titleFontSize ?? 20.0;
    contentFontSize = widget.note?.contentFontSize ?? 16.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(titleFontSizeProvider.notifier).setFontSize(titleFontSize);
      ref.read(contentFontSizeProvider.notifier).setFontSize(contentFontSize);
    });
  }

  // 🔥 NEW: Title font picker
  void _showTitleFontPicker() async {
    final selectedFont = await showFontPickerDialog(context);
    if (selectedFont != null && mounted) {
      setState(() => titleFontFamily = selectedFont);
    }
  }

  // 🔥 NEW: Content font picker
  void _showContentFontPicker() async {
    final selectedFont = await showFontPickerDialog(context);
    if (selectedFont != null && mounted) {
      setState(() => contentFontFamily = selectedFont);
    }
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
    setState(() {
      isEditing = _titleFocusNode.hasFocus || _contentFocusNode.hasFocus;
    });
  }

  void _showTitleColorPicker() async {
    final selectedColor = await showNoteColorPicker(context);
    if (selectedColor != null && mounted) {
      setState(() => titleColor = selectedColor);
    }
  }

  void _showContentColorPicker() async {
    final selectedColor = await showNoteColorPicker(context);
    if (selectedColor != null && mounted) {
      setState(() => contentColor = selectedColor);
    }
  }

  void _showColorPicker() async {
    final selectedColor = await showNoteColorPicker(context);
    if (selectedColor != null && mounted) {
      setState(() {
        noteColor = selectedColor;
      });
    }
  }

  bool _isNoteChanged() {
    final prev = widget.note;
    if (prev == null) return true; // new note = always “changed”

    return prev.title != title ||
        prev.content != content ||
        prev.color != _colorToHex(noteColor) ||
        prev.titleTextColor != _colorToHex(titleColor) ||
        prev.contentTextColor != _colorToHex(contentColor) ||
        prev.titleFontFamily != titleFontFamily ||
        prev.contentFontFamily != contentFontFamily ||
        prev.titleFontSize != titleFontSize ||
        prev.contentFontSize != contentFontSize;
  }

  // ✅ ADD THIS - Update _isSaveButtonEnabled() to include todos
  bool _isSaveButtonEnabled() {
    if (widget.note?.id == null) return true; // New note always enabled

    // ✅ Check title/content + checklist changes
    return _isNoteChanged() || _hasTodoChanges();
  }

  void _updateSaveButtonEnablement() {
    // Push latest text from controllers into `title`/`content`
    title = _titleController.text;
    content = _contentController.text;

    setState(() {
      // force rebuild of Save button text
    });
  }

  void _save() async {
    if (_isSaving) return;

    final messenger = ScaffoldMessenger.of(context);

    try {
      // ✅ Push latest text into our fields before saving
      setState(() {
        title = _titleController.text;
        content = _contentController.text;
      });

      if (!_formKey.currentState!.validate()) return;
      _formKey.currentState!.save();

      // ✅ Generate createdAt only for NEW notes
      final String createdAt = widget.note?.id == null
          ? DateTime.now().toIso8601String()
          : widget.note!.createdAt;

      final note = Note(
        id: widget.note?.id,
        title: title,
        content: content,
        color: _colorToHex(noteColor),
        titleTextColor: _colorToHex(titleColor),
        contentTextColor: _colorToHex(contentColor),
        titleFontFamily: titleFontFamily,
        contentFontFamily: contentFontFamily,
        category: widget.note?.category ?? 'Personal',
        createdAt: createdAt,
        titleFontSize: titleFontSize,
        contentFontSize: contentFontSize,
        todoList: List<TodoItem>.from(_todoList), // ✅ defensive copy
      );

      if (widget.note?.id == null) {
        final newId = await DatabaseService.addNote(note);

        if (!mounted) return; // ✅ FIX

        final noteWithId = note.copyWith(id: newId);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(todoNotesProvider.notifier).addTodoNote(noteWithId);
        });

        Navigator.pop(context, noteWithId);
      } else {
        // EXISTING note (edit)
        await DatabaseService.updateNote(note);

        if (!mounted) return; // ✅ FIX

        // ✅ Update provider directly (no need for post frame)
        ref.read(todoNotesProvider.notifier).updateTodoNote(note);

        // ✅ Safe to use context now
        Navigator.pop(context, note);
      }

      // ✅ Unfocus and exit editing UI
      _titleFocusNode.unfocus();
      _contentFocusNode.unfocus();
      setState(() => isEditing = false);

      // ✅ Show success
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            textAlign: TextAlign.center,
            widget.note?.id == null ? 'Note created!' : 'Note updated!',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        debugPrint('$e');
        messenger.showSnackBar(
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

  // ✅ NEW: build checklist UI
  Widget _buildChecklistView() {
    return ListView.builder(
      itemCount: _todoList.length + 1,
      padding: const EdgeInsets.only(bottom: 100),
      itemBuilder: (context, index) {
        if (index == _todoList.length) {
          return const SizedBox(height: 80);
        }

        final item = _todoList[index];

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          dense: true,

          leading: Checkbox(
            value: item.isCompleted,
            onChanged: (value) {
              setState(() {
                _todoList[index] = TodoItem(
                  id: item.id,
                  text: item.text,
                  isCompleted: value ?? false,
                );
                isEditing = true;
              });
              _checkTodoChanges();
            },
          ),

          title: TextFormField(
            initialValue: item.text,
            decoration: const InputDecoration(
              hintText: 'Task',
              border: InputBorder.none,
              isDense: true,
            ),
            maxLines: 2,
            style: const TextStyle(fontSize: 14),
            onChanged: (newText) {
              setState(() {
                _todoList[index] = TodoItem(
                  id: item.id,
                  text: newText,
                  isCompleted: item.isCompleted,
                );
              });
              _checkTodoChanges();
            },
          ),

          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              setState(() {
                _todoList.removeAt(index);
                isEditing = true;
              });
              _checkTodoChanges();
            },
          ),
        );
      },
    );
  }

  // ✅ Track if todo list changed
bool _hasTodoChanges() {
    final original = widget.note?.todoList ?? [];

    final Map<String, TodoItem> oldMap = {
      for (var item in original) item.id: item,
    };

    final Map<String, TodoItem> newMap = {
      for (var item in _todoList) item.id: item,
    };

    if (oldMap.length != newMap.length) return true;

    for (final id in newMap.keys) {
      final oldItem = oldMap[id];
      final newItem = newMap[id];

      if (oldItem == null || newItem == null) return true;

      if (oldItem.text.trim() != newItem.text.trim()) return true;

      if (oldItem.isCompleted != newItem.isCompleted) return true;
    }

    return false;
  }

  // ✅ Force save button update
  void _checkTodoChanges() {
    setState(() {}); // Triggers _isSaveButtonEnabled() check
  }

  // Add this method
  Future<void> _captureNoteContent() async {
    if (_isCapturing) return; // Prevent double taps

    setState(() {
      _isCapturing = true; // 🔥 INSTANT visual feedback
    });

    debugPrint('🔥 Camera tapped!');

    final screenWidth = MediaQuery.of(context).size.width;

    final noteContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          // ← ADD THIS
          child: Container(
            constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
            child: Text(
              content.isEmpty ? 'Your content here' : content,
              textAlign: TextAlign.start,
              maxLines: null, // Allow unlimited lines
              overflow: TextOverflow.visible, // Don't clip
              style: TextStyle(
                fontFamily: contentFontFamily,
                color: contentColor,
                fontSize: contentFontSize,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );

    final noteWidget = Material(
      color: noteColor,
      child: Padding(
        padding: EdgeInsets.all(32),
        child: IntrinsicHeight(child: IntrinsicWidth(child: noteContent)),
      ),
    );

    try {
      final image = await screenshotController.captureFromWidget(
        noteWidget,
        delay: Duration(milliseconds: 1),
        pixelRatio: 8.0, // 🔥 CRISP, PROFESSIONAL QUALITY
      );

      debugPrint(' Ultra HD Image: ${image.length} bytes');
      if (mounted) {
        _showScreenshotDialog(image); // Your existing dialog
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      // 🔥 Reset animation when done
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
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
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _contentController.dispose();
    _titleFocusNode.removeListener(_handleFocusChange);
    _contentFocusNode.removeListener(_handleFocusChange);
    _numberingNotifier.dispose();
    // _contentScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //  Watch SEPARATE providers for each field
    final titleSize = ref.watch(titleFontSizeProvider);
    final contentSize = ref.watch(contentFontSizeProvider);
    final screenWidth = Func().screenWidth(context);

    debugPrint('screenHeight:$screenWidth\n');

    // 🔥 Sync INDEPENDENTLY
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
            // Numbering icon
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
                // In your NoteFormWidget build method, UPDATE this line:
                NoteBottomSheet(
                  onCancel: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                  },
                  onSave: _save,
                  onAddTask: () {
                    setState(() {
                      _todoList.add(
                        TodoItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          text: '',
                          isCompleted: false,
                        ),
                      );
                    });
                  },
                  isSaving: _isSaving,
                  isSaveButtonEnabled: _isSaveButtonEnabled(),
                  isChecklistMode: _isChecklistMode, // ✅ IMPORTANT
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
                    // ✅ Wrap checklist with GestureDetector for tap-to-edit
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
                    NoteContentField(
                      controller: _contentController,
                      focusNode: _contentFocusNode,
                      fontFamily: contentFontFamily,
                      textColor: contentColor,
                      fontSize: contentFontSize,
                    ),
                  ],
                ],
              ),
            ),
          ),
          //  FIXED: Positioned screenshot button - now properly inside Stack
          Positioned(
            right: 20,
            bottom: 100, // Above bottomSheet
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
