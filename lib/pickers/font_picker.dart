import 'package:flutter/material.dart';
import 'package:notibuku/models/fonts.dart';

Future<String?> showFontPickerDialog(BuildContext context) async {
  var availableFonts = AppFonts.availableFonts;
  var uniqueFonts = availableFonts.toSet();

  final chosenFont = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: 120,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Horizontal scrollable font previews
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: uniqueFonts.map((font) {
                    return GestureDetector(
                      onTap: () => Navigator.pop(context, font),
                      child: Container(
                        alignment: Alignment.center,
                        width: 50,
                        height: 50,
                        margin: EdgeInsets.only(right: 12),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          // vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          backgroundBlendMode: BlendMode.screen,
                          color: Colors.grey[100],

                          border: Border.all(color: Colors.grey[300]!),
                          shape: BoxShape.circle,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              child: Text(
                                textAlign: TextAlign.center,
                                'Aa',
                                style: TextStyle(
                                  fontFamily: font,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,

                                  // height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  return chosenFont;
}
