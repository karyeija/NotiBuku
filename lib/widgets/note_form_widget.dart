import 'package:notibuku/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  String? selectedCategory;
  bool _isCapturing = false; // Track capture state
  final _formKey = GlobalKey<FormState>();
  String title = '', content = '';
  Color noteColor = Colors.white;
  Color titleColor = Colors.black87;
  Color contentColor = Colors.black87;
  bool _isSaving = false;
  bool isEditing = false;
  final TextEditingController _contentController = TextEditingController();
  late FocusNode _titleFocusNode;
  late FocusNode _contentFocusNode;
  late ValueNotifier<bool> _numberingNotifier;
  String titleFontFamily = 'Roboto';
  String contentFontFamily = 'Roboto';
  double titleFontSize = 20.0;
  double contentFontSize = 16.0;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();

    // 🔥 1. Initialize ALL controllers FIRST
    title = widget.note?.title ?? '';
    content = widget.note?.content ?? '';
    noteColor = _hexToColor(widget.note?.color ?? '#FFFFFF');
    titleColor = _hexToColor(widget.note?.titleTextColor ?? '#000000');
    contentColor = _hexToColor(widget.note?.contentTextColor ?? '#000000');
    selectedCategory = widget.note?.category ?? 'Personal';

    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();
    // 🔥 REMOVE: _contentScrollController = ScrollController(); - no longer needed

    _titleFocusNode.addListener(_handleFocusChange);
    _contentFocusNode.addListener(_handleFocusChange);
    _contentController.text = content;
    _numberingNotifier = ValueNotifier(false);

    titleFontFamily = widget.note?.titleFontFamily ?? 'Roboto';
    contentFontFamily = widget.note?.contentFontFamily ?? 'Roboto';
    titleFontSize = widget.note?.titleFontSize ?? 20.0;
    contentFontSize = widget.note?.contentFontSize ?? 16.0;

    // 🔥 2. ONLY providers - NO scroll listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(titleFontSizeProvider.notifier).setFontSize(titleFontSize);
      ref.read(contentFontSizeProvider.notifier).setFontSize(contentFontSize);
      // 🔥 REMOVED ENTIRE problematic scroll listener
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

  void _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final messenger = ScaffoldMessenger.of(context);

    try {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        final note = Note(
          id: widget.note?.id, // null = NEW note
          title: title,
          content: content,
          color: _colorToHex(noteColor),
          titleTextColor: _colorToHex(titleColor),
          contentTextColor: _colorToHex(contentColor),
          titleFontFamily: titleFontFamily,
          contentFontFamily: contentFontFamily,
          category: widget.note?.category ?? 'Personal',
          createdAt: widget.note?.createdAt ?? DateTime.now().toIso8601String(),
          titleFontSize: titleFontSize,
          contentFontSize: contentFontSize,
        );

        // 🔥 PERFECT LOGIC:
        if (widget.note?.id == null) {
          // NEW note (no ID yet)
          int _ = await DatabaseService.addNote(note);
        } else {
          // EDIT existing note
          await DatabaseService.updateNote(note);
        }

        // 🔥 FIXED: Remove editing focus INSTEAD of closing page
        _titleFocusNode.unfocus();
        _contentFocusNode.unfocus();

        // Hide editing UI (bottom sheet)
        setState(() => isEditing = false);

        // Success message
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              textAlign: TextAlign.center,
              widget.note?.id == null ? ' Note created!' : ' Note updated!',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
        Container(
          constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
          child: Text(
            content.isEmpty ? 'Your content here' : content,
            textAlign: TextAlign.start,
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
      builder: (BuildContext dialogContext) => Scaffold(
        appBar: AppBar(title: Text('Note Preview')),
        body: Stack(
          children: [
            // Screenshot preview
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.memory(image),
              ),
            ),
            // Action buttons
            Positioned(
              bottom: 100,
              right: 20,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: 'save',
                    backgroundColor: Colors.green,
                    onPressed: () async {
                      Navigator.of(dialogContext).pop(); // Close dialog first
                      await Helpers().shareOrSaveImage(
                        context: context, // Use MAIN widget context
                        image,
                        saveToGallery: true,
                      );
                      // 🔥 FIXED: Use main ScaffoldMessenger
                      if (mounted && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Screenshot saved to gallery!'),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 3),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }
                    },
                    child: Icon(Icons.download),
                  ),
                  SizedBox(height: 12),
                  FloatingActionButton(
                    heroTag: 'share',
                    backgroundColor: Colors.blue,
                    onPressed: () async {
                      Navigator.of(dialogContext).pop(); // Close dialog first
                      await Helpers().shareOrSaveImage(context: context, image);
                      // 🔥 FIXED: Use main ScaffoldMessenger
                      if (mounted && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.share, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Screenshot shared successfully!'),
                              ],
                            ),
                            backgroundColor: Colors.blue,
                            duration: Duration(seconds: 3),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }
                    },
                    child: Icon(Icons.share),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    // 🔥 Watch SEPARATE providers for each field
    final titleSize = ref.watch(titleFontSizeProvider);
    final contentSize = ref.watch(contentFontSizeProvider);
    final screenWidth = Func().screenWidth(context);

    /// screenWidth <= 322;
    final bool isSmall = screenWidth <= 322;
    final bool isMedium = screenWidth > 322 && screenWidth <= 700;

    debugPrint('screenHeight:$screenWidth\n');

    // 🔥 Sync INDEPENDENTLY
    if (titleFontSize != titleSize) titleFontSize = titleSize;
    if (contentFontSize != contentSize) contentFontSize = contentSize;

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
      bottomSheet: !isEditing
          ? null
          : Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                color: Colors.green[900],
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: FittedBox(
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : SizedBox(
                                child: const Text(
                                  'Save',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  CircleAvatar(
                                    maxRadius: isSmall
                                        ? screenWidth * 0.06
                                        : isMedium
                                        ? screenWidth * 0.05
                                        : screenWidth * 0.03,
                                    backgroundColor: Colors.red,
                                    child: IconButton(
                                      padding: EdgeInsets
                                          .zero, // Remove button padding

                                      icon: FittedBox(
                                        child: Text(
                                          'T.F',
                                          style: TextStyle(
                                            fontSize: isSmall
                                                ? screenWidth *
                                                      0.05 // Reduced sizes
                                                : isMedium
                                                ? screenWidth *
                                                      0.03 // Reduced sizes
                                                : screenWidth *
                                                      0.03, // Adjusted for large
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: titleFontFamily,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      onPressed: _showTitleFontPicker,
                                    ),
                                  ),

                                  // SizedBox(width: 16),
                                  Text(
                                    'Title',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      // fontFamily: titleFontFamily,
                                    ),
                                  ),
                                  CircleAvatar(
                                    maxRadius: isSmall
                                        ? screenWidth * 0.06
                                        : isMedium
                                        ? screenWidth * 0.05
                                        : screenWidth * 0.03,
                                    backgroundColor:
                                        titleColor.computeLuminance() > 0.5
                                        ? Colors.black87
                                        : Colors.white,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Container(
                                        width: isSmall
                                            ? screenWidth * 0.95
                                            : isMedium
                                            ? screenWidth * 0.4
                                            : screenWidth * 0.5,
                                        height: isSmall
                                            ? screenWidth *
                                                  0.09 // Reduced sizes
                                            : isMedium
                                            ? screenWidth *
                                                  0.09 // Reduced sizes
                                            : screenWidth * 0.05,
                                        decoration: BoxDecoration(
                                          color: titleColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.title,
                                            size: isSmall
                                                ? screenWidth *
                                                      0.07 // Reduced sizes
                                                : isMedium
                                                ? screenWidth *
                                                      0.05 // Reduced sizes
                                                : screenWidth * 0.048,
                                            color:
                                                titleColor.computeLuminance() >
                                                    0.5
                                                ? Colors.black87
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                      onPressed: _showTitleColorPicker,
                                    ),
                                  ),
                                ],
                              ),
                              // Title slider
                              FontSizeSlider(
                                minFontSize: 12,
                                maxFontSize: 32,
                                isTitle: true,
                                containerColor: const Color.fromARGB(
                                  255,
                                  73,
                                  8,
                                  3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  //content font picker
                                  CircleAvatar(
                                    maxRadius: isSmall
                                        ? screenWidth * 0.06
                                        : isMedium
                                        ? screenWidth * 0.05
                                        : screenWidth * 0.03,
                                    backgroundColor: Colors.red,
                                    child: FittedBox(
                                      // ← This fixes text overflow
                                      child: IconButton(
                                        padding: EdgeInsets
                                            .zero, // Remove button padding

                                        icon: Text(
                                          'C.F',
                                          style: TextStyle(
                                            fontSize: isSmall
                                                ? screenWidth *
                                                      0.05 // Reduced sizes
                                                : isMedium
                                                ? screenWidth *
                                                      0.04 // Reduced sizes
                                                : screenWidth *
                                                      0.03, // Adjusted for large
                                            color: Colors.white,
                                            fontFamily: contentFontFamily,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        onPressed: _showContentFontPicker,
                                      ),
                                    ),
                                  ),
                                  FittedBox(
                                    child: Text(
                                      'Content',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),

                                  // Content color picker
                                  CircleAvatar(
                                    maxRadius: isSmall
                                        ? screenWidth * 0.06
                                        : isMedium
                                        ? screenWidth * 0.05
                                        : screenWidth * 0.03,
                                    backgroundColor:
                                        contentColor.computeLuminance() > 0.5
                                        ? Colors.black87
                                        : Colors.white60,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Container(
                                        padding: EdgeInsets.zero,
                                        width: isSmall
                                            ? screenWidth * 0.08
                                            : isMedium
                                            ? screenWidth * 0.8
                                            : screenWidth * 0.048,
                                        height: isSmall
                                            ? screenWidth *
                                                  0.08 // Reduced sizes
                                            : isMedium
                                            ? screenWidth *
                                                  0.08 // Reduced sizes
                                            : screenWidth * 0.06,
                                        decoration: BoxDecoration(
                                          color: contentColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.format_color_fill_outlined,
                                          size: isSmall
                                              ? screenWidth *
                                                    0.05 // Reduced sizes
                                              : isMedium
                                              ? screenWidth *
                                                    0.03 // Reduced sizes
                                              : screenWidth * 0.025,
                                          color:
                                              contentColor.computeLuminance() >
                                                  0.5
                                              ? Colors.black87
                                              : Colors.white,
                                        ),
                                      ),
                                      onPressed: _showContentColorPicker,
                                    ),
                                  ),
                                ],
                              ),
                              FontSizeSlider(minFontSize: 10, maxFontSize: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: Func().screenHeight(context) * 0.1,
                      child: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        focusNode: _titleFocusNode,
                        initialValue: title,
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(
                          fontFamily: titleFontFamily,
                          color: titleColor,
                          fontSize: titleFontSize, // 🔥 REAL-TIME UPDATE!
                          fontWeight: FontWeight.bold,
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Required" : null,
                        onSaved: (v) => title = v ?? '',
                        maxLines: 1,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      // controller: _contentScrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        8.0,
                        0,
                        0,
                        MediaQuery.of(context).viewInsets.bottom / 1.8,
                      ),
                      child: TextFormField(
                        controller: _contentController,
                        focusNode: _contentFocusNode,
                        style: TextStyle(
                          fontFamily: contentFontFamily,
                          color: contentColor,
                          fontSize: contentFontSize,
                        ),
                        decoration: const InputDecoration(
                          hintText:
                              '🔦Select lines and tap numbering icon to toggle numbered list',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(16),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Required" : null,
                        onSaved: (v) => content = v ?? '',
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        maxLines: null,
                        scrollPhysics: const NeverScrollableScrollPhysics(),
                        scrollController: null,
                        scrollPadding: const EdgeInsets.all(20.0),
                        minLines: 8, //ADDED: Natural minimum height
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 🔥 FIXED: Positioned screenshot button - now properly inside Stack
          Positioned(
            right: 20,
            bottom: 100, // Above bottomSheet
            child: _buildScreenshotButton(screenWidth),
          ),
        ],
      ),
    );
  }

  // Your screenshot button with animation:
  Widget _buildScreenshotButton(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: GestureDetector(
        onTap: _isCapturing ? null : _captureNoteContent,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.all(12),
          transform: Matrix4.identity()
            ..scaledByDouble(_isCapturing ? 0.9 : 1.0, 1, 1, 1),
          child: RotatedBox(
            quarterTurns: 1,
            child: Icon(
              _isCapturing ? Icons.screenshot : Icons.screenshot_outlined,
              color: _isCapturing ? Colors.orange : Colors.black87,
              size: screenWidth * 0.09,
            ),
          ),
        ),
      ),
    );
  }
}
