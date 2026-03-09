import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:notibuku/models/note.dart';
import 'package:notibuku/pickers/color_picker.dart';
import 'package:notibuku/pickers/font_picker.dart';
import 'package:notibuku/services/note_services.dart';
import 'package:notibuku/services/sizefactor.dart';
import 'package:notibuku/widgets/fontslider.dart';
import 'package:media_gallery_saver/media_gallery_saver.dart';

class NoteFormWidget extends ConsumerStatefulWidget {
  final Note? note;
  const NoteFormWidget({super.key, this.note});

  @override
  ConsumerState<NoteFormWidget> createState() => _NoteFormWidgetState();
}

class _NoteFormWidgetState extends ConsumerState<NoteFormWidget> {
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
    title = widget.note?.title ?? '';
    content = widget.note?.content ?? '';
    noteColor = _hexToColor(widget.note?.color ?? '#FFFFFF');
    titleColor = _hexToColor(widget.note?.titleTextColor ?? '#000000');
    contentColor = _hexToColor(widget.note?.contentTextColor ?? '#000000');

    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();
    _titleFocusNode.addListener(_handleFocusChange);
    _contentFocusNode.addListener(_handleFocusChange);
    _contentController.text = content;
    _numberingNotifier = ValueNotifier(false);

    titleFontFamily = widget.note?.titleFontFamily ?? 'Roboto';
    contentFontFamily = widget.note?.contentFontFamily ?? 'Roboto';
    titleFontSize = widget.note?.titleFontSize ?? 20.0;
    contentFontSize = widget.note?.contentFontSize ?? 16.0;

    // 🔥 Initialize Riverpod with our values
    // 🔥 Initialize separate providers
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

  void _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final messenger = ScaffoldMessenger.of(context);
    final navMessenger = Navigator.of(context);

    try {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        final note = Note(
          id: widget.note?.id,
          title: title,
          content: content,
          color: _colorToHex(noteColor),
          titleTextColor: _colorToHex(titleColor),
          contentTextColor: _colorToHex(contentColor),
          titleFontFamily: titleFontFamily,
          contentFontFamily: contentFontFamily,
          createdAt: widget.note?.createdAt ?? DateTime.now().toIso8601String(),
          titleFontSize: titleFontSize,
          contentFontSize: contentFontSize,
        );

        if (widget.note == null) {
          int _ = await DatabaseService.addNote(note);
        } else {
          if (note.id == null) throw Exception('Update failed: id is null');
          await DatabaseService.updateNote(note);
        }

        if (context.mounted) {
          navMessenger.pop(true);
        }
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
            textAlign: TextAlign.center,
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
        delay: Duration(milliseconds: 100),
        pixelRatio: 8.0, // 🔥 CRISP, PROFESSIONAL QUALITY
      );

      debugPrint('✅ Ultra HD Image: ${image.length} bytes');
      if (mounted) {
        _showScreenshotDialog(image);
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  Future<bool> _requestStoragePermission() async {
    // Android 13+ (API 33+): Use media permissions
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    // Request appropriate storage permission
    PermissionStatus status;

    if (Platform.isAndroid) {
      // Try media images first (Android 13+)
      status = await Permission.photos.request();
      if (!status.isGranted) {
        // Fallback to storage (older Android)
        status = await Permission.storage.request();
      }
    } else {
      // iOS uses photos permission
      status = await Permission.photos.request();
    }

    if (status.isPermanentlyDenied) {
      // Open settings
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  Future<void> _shareOrSaveImage(
    Uint8List imageBytes, {
    bool saveToGallery = false,
  }) async {
    try {
      if (saveToGallery && !(await _requestStoragePermission())) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Storage permission denied'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = '${directory.path}/notibuku_$timestamp.png';
      final file = File(imagePath);
      await file.writeAsBytes(imageBytes);

      if (saveToGallery) {
        // 🔥 media_gallery_saver - Perfect API match!
        final saver = MediaGallerySaver();
        final success = await saver.saveMediaFromFile(file: file);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Saved to Gallery!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Your SharePlus unchanged 👇
        try {
          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(imagePath, name: 'notibuku_note.png')],
              // text: 'Check out my NotiBuku note!',
            ),
          );
        } catch (shareError) {
          debugPrint('$shareError');
        }
      }

      await file.delete();
    } catch (e) {
      debugPrint('Share failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showScreenshotDialog(Uint8List image) {
    showDialog(
      context: context,
      builder: (context) => Scaffold(
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
                    onPressed: () {
                      Navigator.pop(context);
                      _shareOrSaveImage(image, saveToGallery: true);
                    },
                    child: Icon(Icons.download),
                  ),
                  SizedBox(height: 12),
                  FloatingActionButton(
                    heroTag: 'share',
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      Navigator.pop(context);
                      _shareOrSaveImage(image);
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
                widget.note == null ? 'New Note' : 'Edit Note',
                style: const TextStyle(color: Colors.white),
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
      bottomSheet: Container(
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
            // Container(
            //   width: double.infinity,
            //   height: 40,
            //   decoration: BoxDecoration(
            //     color: titleColor,
            //     shape: BoxShape.rectangle,
            //     border: Border.all(color: Colors.white, width: 2),
            //   ),
            // ),
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
                GestureDetector(
                  onTap: _captureNoteContent,
                  child: FaIcon(
                    FontAwesomeIcons.camera,
                    color: Colors.white,
                    size: screenWidth * 0.06,
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
                            valueColor: AlwaysStoppedAnimation(Colors.white),
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
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            CircleAvatar(
                              maxRadius: isSmall
                                  ? screenWidth * 0.06
                                  : isMedium
                                  ? screenWidth * 0.05
                                  : screenWidth * 0.03,
                              backgroundColor: Colors.red,
                              child: IconButton(
                                padding:
                                    EdgeInsets.zero, // Remove button padding

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
                                      color: titleColor.computeLuminance() > 0.5
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
                          containerColor: const Color.fromARGB(255, 73, 8, 3),
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
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                  padding:
                                      EdgeInsets.zero, // Remove button padding

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
                                    color: contentColor.computeLuminance() > 0.5
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
      body: Padding(
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
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 0, 0, 100),
                  child: TextFormField(
                    controller: _contentController,
                    focusNode: _contentFocusNode,
                    style: TextStyle(
                      fontFamily: contentFontFamily,
                      color: contentColor,
                      fontSize: contentFontSize, // 🔥 REAL-TIME UPDATE!
                    ),
                    decoration: const InputDecoration(
                      hintText:
                          '🔦Select lines and tap numbering icon to toggle numbered list',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Required" : null,
                    onSaved: (v) => content = v ?? '',
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                ),
              ),
              SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class AutoNumberListFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue;
  }

  static String removeNumberingFromLines(String text, int start, int end) {
    final fullLines = text.split('\n');
    final startLine = _lineIndexAtOffset(fullLines, start);
    final endLine = _lineIndexAtOffset(fullLines, end);

    final cleanedLines = <String>[];
    for (int i = 0; i < fullLines.length; i++) {
      if (i >= startLine && i <= endLine) {
        final line = fullLines[i];
        // Fixed: Only remove if line actually has numbering, preserve original spaces
        final cleaned = RegExp(r'^\s*\d+\.\s*').hasMatch(line)
            ? line.replaceAll(RegExp(r'^\s*\d+\.\s*'), '')
            : line;
        cleanedLines.add(cleaned);
      } else {
        cleanedLines.add(fullLines[i]);
      }
    }
    return cleanedLines.join('\n');
  }

  static String numberSelectedLines(String text, int start, int end) {
    final fullLines = text.split('\n');
    final startLine = _lineIndexAtOffset(fullLines, start);
    final endLine = _lineIndexAtOffset(fullLines, end);

    final numberedLines = <String>[];
    int nextNumber = 1;

    for (int i = 0; i < fullLines.length; i++) {
      final originalLine = fullLines[i];

      if (i >= startLine && i <= endLine) {
        // Fixed: Skip empty lines and only number lines with actual content
        if (_isEmptyOrJustSpaces(originalLine)) {
          numberedLines.add(originalLine);
          continue;
        }

        // Check if already numbered
        if (RegExp(r'^\s*\d+\.\s').hasMatch(originalLine)) {
          // Preserve existing numbering and continue sequence
          final match = RegExp(r'^\s*(\d+)').firstMatch(originalLine);
          if (match != null) {
            nextNumber = int.parse(match.group(1)!) + 1;
          }
          numberedLines.add(originalLine);
        } else {
          // Number this line, preserve original leading spaces
          final leadingSpaces =
              RegExp(r'^(\s*)').firstMatch(originalLine)?.group(1) ?? '';
          final content = originalLine.trim();
          numberedLines.add('$leadingSpaces$nextNumber. $content');
          nextNumber++;
        }
      } else {
        // Update nextNumber counter for existing numbered lines outside selection
        if (RegExp(r'^\s*\d+\.\s').hasMatch(originalLine)) {
          final match = RegExp(r'^\s*(\d+)').firstMatch(originalLine);
          if (match != null) {
            nextNumber = int.parse(match.group(1)!) + 1;
          }
        }
        numberedLines.add(originalLine);
      }
    }

    return numberedLines.join('\n');
  }

  // Helper: Check if line is empty or just whitespace
  static bool _isEmptyOrJustSpaces(String line) {
    return line.trim().isEmpty || line.trim() == '';
  }

  static int _lineIndexAtOffset(List<String> lines, int offset) {
    int currentOffset = 0;
    for (int i = 0; i < lines.length; i++) {
      if (offset <= currentOffset + lines[i].length) return i;
      currentOffset += lines[i].length + 1; // +1 for newline
    }
    return lines.length - 1;
  }
}
