import 'package:flutter/material.dart';
import 'package:notibuku/models/fonts.dart';
import 'package:notibuku/services/sizefactor.dart';

Future<String?> showFontPickerDialog(BuildContext context) async {
  var availableFonts = AppFonts.availableFonts;
  var uniqueFonts = availableFonts.toSet();

  final chosenFont = await showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 20),
    pageBuilder:
        (
          BuildContext buildContext,
          Animation animation,
          Animation secondaryAnimation,
        ) {
          var pageWidth = MediaQuery.of(context).size.width;
          double dialogWidth = pageWidth * 0.45;
          double sizeFactor = getSizeFactor(context);

          double radius = sizeFactor * 0.02;
          return Stack(
            children: [
              Positioned(
                top: sizeFactor * 0.1,
                right: pageWidth * 0.02,
                child: Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(radius),
                      topRight: Radius.circular(radius),
                    ),
                  ),
                  elevation: 24,
                  child: Container(
                    width: dialogWidth,
                    padding: EdgeInsets.all(0),
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Text(
                            'Select Font',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: sizeFactor * 0.03,
                              fontFamily: "alger".toUpperCase(),
                            ),
                          ),
                        ),
                        Divider(color: Colors.red),
                        SizedBox(
                          height:
                              sizeFactor *
                              0.6, // Fixed height for the scroll area
                          child: SingleChildScrollView(
                            child: Column(
                              children: uniqueFonts.map((font) {
                                return ListTile(
                                  selectedColor: Colors.amber,
                                  title: Text(
                                    textAlign: TextAlign.center,
                                    font,
                                    style: TextStyle(
                                      fontFamily: font,
                                      fontSize: sizeFactor * 0.03,
                                    ),
                                  ),
                                  onTap: () => Navigator.pop(context, font),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
  );
  return chosenFont;

  // if (chosenFont != null) {
  //   ref.read(fontFamilyProvider.notifier).state = chosenFont;
  // }
}
