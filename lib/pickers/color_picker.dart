// // ignore_for_file: invalid_use_of_visible_for_testing_member

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:notibuku/models/colors.dart';
// import 'package:notibuku/providers/font_color_provider.dart';
// import 'package:notibuku/services/sizefactor.dart';
// import 'package:notibuku/widgets/styled_text.dart';

// Future<void> showColorPickerDialog(BuildContext context, WidgetRef ref) async {
//   final availableColors = AppColors.availableColors;
//   var uniqueColors = availableColors.toSet();
//   double sizeFactor = getSizeFactor(context);

//   final chosenColor = await showGeneralDialog<Color>(
//     context: context,
//     barrierDismissible: true,
//     barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
//     barrierColor: Colors.black54,
//     transitionDuration: const Duration(milliseconds: 20),
//     pageBuilder:
//         (
//           BuildContext buildContext,
//           Animation animation,
//           Animation secondaryAnimation,
//         ) {
//           var pageWidth = MediaQuery.of(context).size.width;
//           double dialogWidth = sizeFactor * 0.3;

//           var pageHeight = UIHelpers.pageHeight(context);
//           double radius = sizeFactor * 0.03;
//           return Stack(
//             children: [
//               Positioned(
//                 top: pageHeight * 0.12,
//                 left: pageWidth * 0.2,
//                 child: Material(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(radius),
//                       topRight: Radius.circular(radius),
//                     ),
//                   ),
//                   elevation: 24,
//                   child: Container(
//                     width: dialogWidth,
//                     padding: EdgeInsets.zero,
//                     color: Colors.white,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           'Choose Color',
//                           style: TextStyle(
//                             color: Colors.blue,
//                             fontSize: sizeFactor * 0.03,
//                             fontFamily: "alger".toUpperCase(),
//                           ),
//                         ),
//                         Divider(color: Colors.red),
//                         SizedBox(
//                           width: sizeFactor * 0.3,
//                           height:
//                               sizeFactor *
//                               0.6, // Fixed height for the scroll area
//                           child: Container(
//                             padding: EdgeInsets.zero,
//                             child: SingleChildScrollView(
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: GridView.count(
//                                   shrinkWrap:
//                                       true, // so it doesn't take infinite height inside Column
//                                   physics:
//                                       NeverScrollableScrollPhysics(), // disable scrolling if inside another scroll
//                                   crossAxisCount: 3, // 3 avatars per row
//                                   mainAxisSpacing:
//                                       8, // vertical spacing between rows
//                                   crossAxisSpacing:
//                                       8, // horizontal spacing between columns
//                                   children: uniqueColors.map((color) {
//                                     return MouseRegion(
//                                       cursor: SystemMouseCursors.click,
//                                       child: GestureDetector(
//                                         onTap: () =>
//                                             Navigator.pop(context, color),
//                                         child: CircleAvatar(
//                                           backgroundColor: color,
//                                           radius:
//                                               sizeFactor *
//                                               0.01, // adjust radius to your need
//                                         ),
//                                       ),
//                                     );
//                                   }).toList(),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//   );

//   if (chosenColor != null) {
//     // ignore: invalid_use_of_protected_member
//     ref.read(fontColorProvider.notifier).state = chosenColor;
//   }
// }
