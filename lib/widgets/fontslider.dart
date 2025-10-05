import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// StateNotifier to manage font size state
class FontSizeNotifier extends StateNotifier<double> {
  FontSizeNotifier() : super(16.0); // Default font size

  void setFontSize(double size) {
    state = size;
  }
}

/// Riverpod provider to expose font size notifier
final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>(
  (ref) => FontSizeNotifier(),
);

/// Helper to get size factor based on screen height
double getSizeFactor(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

/// Slider widget to control font size vertically
class FontSizeSlider extends ConsumerWidget {
  final double? minFontSize;
  final double? maxFontSize;

  const FontSizeSlider({super.key, this.minFontSize, this.maxFontSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(fontSizeProvider);
    final sizeFactor = getSizeFactor(context);

    final double computedMinFontSize =
        minFontSize ?? sizeFactor * 0.04; // e.g. 4% of screen height
    final double computedMaxFontSize =
        maxFontSize ?? sizeFactor * 0.08; // e.g. 8% of screen height

    final sliderHeight = sizeFactor * 0.05;
    final sliderWidth = sizeFactor * 0.339;

    return RotatedBox(
      quarterTurns: -1,
      child: SizedBox(
        width: sliderWidth,
        height: sliderHeight,
        child: Slider(
          value: fontSize.clamp(computedMinFontSize, computedMaxFontSize),
          min: computedMinFontSize,
          max: computedMaxFontSize,
          divisions: ((computedMaxFontSize - computedMinFontSize) * 2).toInt(),
          label: fontSize.toStringAsFixed(1),
          onChanged: (newSize) {
            ref.read(fontSizeProvider.notifier).setFontSize(newSize);
          },
        ),
      ),
    );
  }
}
