// import 'package:flutter/cupertino.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import 'package:notibuku/services/note_services.dart';

// final fontFamilyProvider = StateNotifierProvider<FontFamilyNotifier, String>((
//   ref,
// ) {
//   return FontFamilyNotifier();
// });

// class FontFamilyNotifier extends StateNotifier<String> {
//   static const String _fontFamilyTitle = 'fontFamily';

//   FontFamilyNotifier() : super('Roboto') {
//     // default font family to Roboto
//     _loadFontFamily();
//   }

//   Future<void> _loadFontFamily() async {
//     try {
//       final db = await DatabaseService.instance.database;
//       final results = await db.query(
//         'notisi',
//         where: 'title = ?',
//         whereArgs: [_fontFamilyTitle],
//       );
//       if (results.isNotEmpty) {
//         final content = results.first['content'] as String? ?? '';
//         if (content.isNotEmpty) {
//           state = content;
//         }
//       }
//     } catch (e, st) {
//       debugPrint('Failed to load font family from DB: $e\n$st');
//     }
//   }

//   Future<void> setFontFamily(String fontFamily) async {
//     state = fontFamily;
//     try {
//       final db = await DatabaseService.instance.database;
//       final existing = await db.query(
//         'notisi',
//         where: 'title = ?',
//         whereArgs: [_fontFamilyTitle],
//       );
//       if (existing.isEmpty) {
//         await db.insert('notisi', {
//           'title': _fontFamilyTitle,
//           'content': fontFamily,
//         });
//       } else {
//         await db.update(
//           'notisi',
//           {'content': fontFamily},
//           where: 'title = ?',
//           whereArgs: [_fontFamilyTitle],
//         );
//       }
//     } catch (e, st) {
//       debugPrint('Failed to save font family to DB: $e\n$st');
//     }
//   }
// }
