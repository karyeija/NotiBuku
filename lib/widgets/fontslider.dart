import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// StateNotifier to manage font size state
class FontSizeNotifier extends StateNotifier<double> {
  FontSizeNotifier() : super(16.0);

  void setFontSize(double size) {
    state = size;
  }
}

/// 🔥 SEPARATE PROVIDERS for Title & Content
final titleFontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>(
  (ref) => FontSizeNotifier(),
);
final contentFontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>(
  (ref) => FontSizeNotifier(),
);

double getSizeFactor(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

class FontSizeSlider extends ConsumerWidget {
  final double? minFontSize;
  final double? maxFontSize;
  final bool isTitle;
  final Color? containerColor; // 🔥 Container color parameter

  const FontSizeSlider({
    super.key,
    this.minFontSize,
    this.maxFontSize,
    this.isTitle = false,
    this.containerColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔥 Use correct provider (font size only)
    final fontSizeProvider = isTitle
        ? titleFontSizeProvider
        : contentFontSizeProvider;

    final fontSize = ref.watch(fontSizeProvider);
    final sizeFactor = getSizeFactor(context);

    final double computedMinFontSize = minFontSize ?? 12.0;
    final double computedMaxFontSize = maxFontSize ?? 32.0;
    final int currentValue = fontSize
        .clamp(computedMinFontSize, computedMaxFontSize)
        .round();

    final selectorHeight = sizeFactor * 0.08;
    final selectorWidth = sizeFactor * 0.23;

    // 🔥 Use containerColor directly - no state management
    final effectiveColor =
        containerColor ?? const Color.fromARGB(255, 20, 0, 109);

    return Container(
      width: selectorWidth,
      height: selectorHeight,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withValues(alpha: .12),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Minus button
          GestureDetector(
            onTap: currentValue > computedMinFontSize.round()
                ? () => ref
                      .read(fontSizeProvider.notifier)
                      .setFontSize((currentValue - 1).toDouble())
                : null,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: currentValue > computedMinFontSize.round()
                    ? Colors.red
                    : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.remove, color: Colors.white, size: 20),
            ),
          ),
          // Current value
          Text(
            '$currentValue',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
              height: 1.0,
            ),
          ),
          // Plus button
          GestureDetector(
            onTap: currentValue < computedMaxFontSize.round()
                ? () => ref
                      .read(fontSizeProvider.notifier)
                      .setFontSize((currentValue + 1).toDouble())
                : null,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: currentValue < computedMaxFontSize.round()
                    ? Colors.green
                    : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
