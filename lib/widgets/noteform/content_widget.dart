import 'package:flutter/material.dart';

class NoteContentField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String fontFamily;
  final Color textColor;
  final double fontSize;

  const NoteContentField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.fontFamily,
    required this.textColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        8.0,
        0,
        0,
        MediaQuery.of(context).viewInsets.bottom / 1.8,
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        style: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          fontSize: fontSize,
        ),
        decoration: const InputDecoration(
          hintText:
              '🔦Select lines and tap numbering icon to toggle numbered list',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(16),
        ),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        onChanged: (text) => controller.text = text,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        maxLines: null,
        scrollPadding: const EdgeInsets.all(20.0),
        minLines: 8,
      ),
    );
  }
}
