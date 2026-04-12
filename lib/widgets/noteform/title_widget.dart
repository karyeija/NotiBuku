import 'package:flutter/material.dart';
import 'package:notibuku/services/sizefactor.dart';

class NoteTitleField extends StatelessWidget {
  final TextEditingController controller; // title controller, not content
  final FocusNode focusNode;
  final String fontFamily;
  final Color textColor;
  final double fontSize;

  const NoteTitleField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.fontFamily,
    required this.textColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: Func().screenHeight(context) * 0.1,
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Title',
            border: OutlineInputBorder(),
          ),
          style: TextStyle(
            fontFamily: fontFamily,
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
          validator: (v) => v == null || v.isEmpty ? "Required" : null,
          // ✅ REMOVE the onChanged override
          maxLines: 1,
          textInputAction: TextInputAction.next,
        ),
      ),
    );
  }
}
