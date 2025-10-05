import 'package:flutter/material.dart';

class UIHelpers {
  // This class can contain static methods for UI-related helpers.
  // For example, you can add methods to create common widgets, styles, etc.
  static double pageHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double pageWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
}

class SnackbarHelpers {
  // This class contains static methods for showing snackbars.
  static void showSnackbar(
    BuildContext context,
    String message,
    Color textColor, {
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = Colors.redAccent,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor, // Use the passed parameter here
        duration: duration,
      ),
    );
  }
}

// This function can be used to style text with ordinal numbers.
// It uses a regular expression to find ordinal numbers and applies the appropriate font feature.
Widget styledText(
  String content, {
  String? fontFamily,
  FontStyle? fontStyle,
  FontWeight? fontWeight,
  double fontSize = 10.0,
  Color fontColor = Colors.black,
  TextOverflow? overflow = TextOverflow.ellipsis,
}) {
  final regExp = RegExp(r'\b(\d+)(st|nd|rd|th)\b', caseSensitive: false);

  final List<TextSpan> spans = [];
  int lastMatchEnd = 0;

  for (final match in regExp.allMatches(content)) {
    // Add normal text before the matched ordinal
    if (match.start > lastMatchEnd) {
      spans.add(
        TextSpan(
          text: content.substring(lastMatchEnd, match.start),
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: fontFamily,
            color: fontColor,
            // normal text, no ordinal font feature
          ),
        ),
      );
    }

    // Add the ordinal text with ordinalForms font feature
    spans.add(
      TextSpan(
        text: match.group(0),
        style: TextStyle(
          color: fontColor,
          fontWeight: fontWeight,
          fontSize: fontSize,
          fontFamily: 'Piazzolla',
          fontFeatures: [FontFeature.ordinalForms()],
        ),
      ),
    );

    lastMatchEnd = match.end;
  }

  // Add remaining normal text after last match
  if (lastMatchEnd < content.length) {
    spans.add(
      TextSpan(
        text: content.substring(lastMatchEnd),
        style: TextStyle(
          fontFamily: fontFamily,
          color: fontColor,
          fontSize: fontSize,
        ),
      ),
    );
  }

  return RichText(
    overflow: overflow ?? TextOverflow.ellipsis, // default to clip if null
    text: TextSpan(
      children: spans,
      style: TextStyle(fontWeight: fontWeight),
    ),
  );
}
