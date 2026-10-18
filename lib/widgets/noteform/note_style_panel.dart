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
    final width = Func().screenWidth(context);
    final small = width <= 322;
    final medium = width <= 700;
    final radius =
        width *
        (small
            ? .06
            : medium
            ? .05
            : .03);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.green[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _section(
            label: 'Title',
            fontLabel: 'T.F',
            fontFamily: titleFontFamily,
            color: titleColor,
            radius: radius,
            fontSize: width * (small ? .05 : .03),
            onFontTap: onShowTitleFontPicker,
            onColorTap: onShowTitleColorPicker,
            colorIcon: Icons.title,
            slider: const FontSizeSlider(
              minFontSize: 12,
              maxFontSize: 32,
              isTitle: true,
              containerColor: Color.fromARGB(255, 73, 8, 3),
            ),
          ),
          _section(
            label: 'Content',
            fontLabel: 'C.F',
            fontFamily: contentFontFamily,
            color: contentColor,
            radius: radius,
            fontSize:
                width *
                (small
                    ? .05
                    : medium
                    ? .04
                    : .03),
            onFontTap: onShowContentFontPicker,
            onColorTap: onShowContentColorPicker,
            colorIcon: Icons.format_color_fill_outlined,
            slider: const FontSizeSlider(minFontSize: 10, maxFontSize: 24),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String label,
    required String fontLabel,
    required String fontFamily,
    required Color color,
    required double radius,
    required double fontSize,
    required VoidCallback onFontTap,
    required VoidCallback onColorTap,
    required IconData colorIcon,
    required Widget slider,
  }) {
    final foreground = color.computeLuminance() > .5
        ? Colors.black87
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _circleButton(
                radius: radius,
                background: Colors.red,
                onTap: onFontTap,
                child: Text(
                  fontLabel,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              _circleButton(
                radius: radius,
                background: foreground,
                onTap: onColorTap,
                child: Container(
                  width: radius * 1.45,
                  height: radius * 1.45,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Icon(colorIcon, size: radius, color: foreground),
                ),
              ),
              slider,
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required double radius,
    required Color background,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: background,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.expand(),
        onPressed: onTap,
        icon: FittedBox(child: child),
      ),
    );
  }
}
