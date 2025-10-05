// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:notibuku/pickers/font_picker.dart';
// import 'package:notibuku/providers/font_family_provider.dart';
// import 'package:notibuku/widgets/styled_text.dart';

// class FontPickerButton extends ConsumerStatefulWidget {
//   const FontPickerButton({super.key});

//   @override
//   ConsumerState<FontPickerButton> createState() => _FontPickerButtonState();
// }

// class _FontPickerButtonState extends ConsumerState<FontPickerButton> {
//   // The screen build context
//   @override
//   Widget build(BuildContext context) {
//     double pageHeight = UIHelpers.pageHeight(context);
//     double pageWidth = UIHelpers.pageWidth(context);
//     var fontFamily = ref.watch(fontFamilyProvider);
//     double radius = pageHeight * 0.015;
//     double sizeFactor = pageHeight > pageWidth ? pageHeight : pageWidth;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: SizedBox(
//         width: sizeFactor * 0.2,
//         height: sizeFactor * 0.05,
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             padding: EdgeInsets.zero,
//             foregroundColor: Colors.white,
//             backgroundColor: const Color.fromARGB(255, 206, 225, 207),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(Radius.circular(radius)),
//             ),
//           ),
//           child: Text(
//             fontFamily,
//             style: TextStyle(
//               fontSize: sizeFactor * 0.03,
//               fontFamily: fontFamily,
//               color: Colors.blue.shade900,
//             ),
//           ),
//           onPressed: () => showFontPickerDialog(context),
//         ),
//       ),
//     );
//   }
// }
