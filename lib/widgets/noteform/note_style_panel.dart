// lib/widgets/noteform/note_style_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notibuku/services/sizefactor.dart';
import 'package:notibuku/widgets/fontslider.dart';

class NoteStylePanel extends ConsumerWidget {
  final ValueNotifier<bool> numberingNotifier;
  final VoidCallback onShowTitleFontPicker;
  final VoidCallback onShowContentFontPicker;
  final VoidCallback onShowTitleColorPicker;
  final VoidCallback onShowContentColorPicker;
  final String titleFontFamily;
  final String contentFontFamily;
  final Color titleColor;
  final Color contentColor;
  final double titleFontSize;
  final double contentFontSize;

  const NoteStylePanel({
    super.key,
    required this.numberingNotifier,
    required this.onShowTitleFontPicker,
    required this.onShowContentFontPicker,
    required this.onShowTitleColorPicker,
    required this.onShowContentColorPicker,
    required this.titleFontFamily,
    required this.contentFontFamily,
    required this.titleColor,
    required this.contentColor,
    required this.titleFontSize,
    required this.contentFontSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = Func().screenWidth(context);
    final bool isSmall = screenWidth <= 322;
    final bool isMedium = screenWidth > 322 && screenWidth <= 700;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: Colors.green[900],
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title buttons row
          Flexible(
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
                        padding: EdgeInsets.zero,
                        icon: FittedBox(
                          child: Text(
                            'T.F',
                            style: TextStyle(
                              fontSize: isSmall
                                  ? screenWidth * 0.05
                                  : isMedium
                                  ? screenWidth * 0.03
                                  : screenWidth * 0.03,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: titleFontFamily,
                            ),
                          ),
                        ),
                        onPressed: onShowTitleFontPicker,
                      ),
                    ),
                    Text(
                      'Title',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    CircleAvatar(
                      maxRadius: isSmall
                          ? screenWidth * 0.06
                          : isMedium
                          ? screenWidth * 0.05
                          : screenWidth * 0.03,
                      backgroundColor: titleColor.computeLuminance() > 0.5
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
                              ? screenWidth * 0.09
                              : isMedium
                              ? screenWidth * 0.09
                              : screenWidth * 0.05,
                          decoration: BoxDecoration(
                            color: titleColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.title,
                              size: isSmall
                                  ? screenWidth * 0.07
                                  : isMedium
                                  ? screenWidth * 0.05
                                  : screenWidth * 0.048,
                              color: titleColor.computeLuminance() > 0.5
                                  ? Colors.black87
                                  : Colors.white,
                            ),
                          ),
                        ),
                        onPressed: onShowTitleColorPicker,
                      ),
                    ),
                  ],
                ),
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
          // Content buttons row
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
                      child: FittedBox(
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Text(
                            'C.F',
                            style: TextStyle(
                              fontSize: isSmall
                                  ? screenWidth * 0.05
                                  : isMedium
                                  ? screenWidth * 0.04
                                  : screenWidth * 0.03,
                              color: Colors.white,
                              fontFamily: contentFontFamily,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: onShowContentFontPicker,
                        ),
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        'Content',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      maxRadius: isSmall
                          ? screenWidth * 0.06
                          : isMedium
                          ? screenWidth * 0.05
                          : screenWidth * 0.03,
                      backgroundColor: contentColor.computeLuminance() > 0.5
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
                              ? screenWidth * 0.08
                              : isMedium
                              ? screenWidth * 0.08
                              : screenWidth * 0.06,
                          decoration: BoxDecoration(
                            color: contentColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.format_color_fill_outlined,
                            size: isSmall
                                ? screenWidth * 0.05
                                : isMedium
                                ? screenWidth * 0.03
                                : screenWidth * 0.025,
                            color: contentColor.computeLuminance() > 0.5
                                ? Colors.black87
                                : Colors.white,
                          ),
                        ),
                        onPressed: onShowContentColorPicker,
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
    );
  }
}
