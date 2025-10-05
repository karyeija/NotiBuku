// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:notibuku/pickers/color_picker.dart';
// import 'package:notibuku/providers/font_color_provider.dart';
// import 'package:notibuku/widgets/styled_text.dart';

// class ColorPickerButton extends ConsumerStatefulWidget {
//   const ColorPickerButton({super.key});

//   @override
//   ConsumerState<ColorPickerButton> createState() => _ColorPickerButtonState();
// }

// class _ColorPickerButtonState extends ConsumerState<ColorPickerButton> {
//   // The screen build context
//   @override
//   Widget build(BuildContext context) {
//     double pageHeight = UIHelpers.pageHeight(context);
//     double pageWidth = UIHelpers.pageWidth(context);
//     double radius = pageHeight * 0.02;
//     double sizeFactor = pageHeight > pageWidth ? pageHeight : pageWidth;

//     var color = ref.watch(fontColorProvider);
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: SizedBox(
//         width: sizeFactor * 0.05,
//         height: sizeFactor * 0.05,
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             padding: EdgeInsets.zero,
//             backgroundColor: const Color.fromARGB(255, 234, 240, 234),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(Radius.circular(radius)),
//             ),
//           ),
//           child: Center(
//             child: Icon(
//               Icons.color_lens,
//               size: sizeFactor * 0.05,
//               color: color,
//             ),
//           ),
//           onPressed: () => showColorPickerDialog(context, ref),
//         ),
//       ),
//     );
//   }
// }
