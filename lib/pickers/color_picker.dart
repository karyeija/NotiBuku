import 'package:flutter/material.dart';
import 'package:notibuku/models/colors.dart';

Future<Color?> showNoteColorPicker(BuildContext context) async {
  final availableColors = AppColors.availableColors; // Fixed: Use the list

  final chosenColor = await showModalBottomSheet<Color>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: 160, // Increased height for better scrolling
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
            // Horizontal scrollable color previews
            Flexible(
              // Changed from Expanded for better constraint handling
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: availableColors.map((color) {
                    return GestureDetector(
                      onTap: () => Navigator.pop(context, color),
                      child: Container(
                        width: 50,
                        height: 50,
                        margin: EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          // Added for ripple effect
                          color: Colors.transparent,
                          child: InkWell(),
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

  return chosenColor;
}
