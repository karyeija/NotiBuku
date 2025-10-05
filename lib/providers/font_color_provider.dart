// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import 'package:notibuku/services/note_services.dart';

// final fontColorProvider = StateNotifierProvider<FontColorNotifier, Color>((
//   ref,
// ) {
//   return FontColorNotifier();
// });

// class FontColorNotifier extends StateNotifier<Color> {
//   static const String _fontColorTitle = 'fontColor';

//   FontColorNotifier() : super(Colors.black) {
//     _loadFontColor();
//   }

//   Future<void> _loadFontColor() async {
//     try {
//       final List<Map<String, dynamic>> results = await db.query(
//         'notisi',
//         where: 'title = ?',
//         whereArgs: [_fontColorTitle],
//       );
//       if (results.isNotEmpty) {
//         final content = results.first['content'] as String? ?? '';
//         final intValue = int.tryParse(content);
//         if (intValue != null) {
//           state = Color(intValue);
//         }
//       }
//     } catch (e, st) {
//       debugPrint('Failed to load font color from DB: $e\n$st');
//     }
//   }

//   Future<void> setFontColor(Color color) async {
//     state = color;
//     try {
//       final db = await DatabaseService.instance.database;
//       final existing = await db.query(
//         'notisi',
//         where: 'title = ?',
//         whereArgs: [_fontColorTitle],
//       );
//       if (existing.isEmpty) {
//         await db.insert('notisi', {
//           'title': _fontColorTitle,
//           'content': color.withValues(red: 0.2).toString(),
//         });
//       } else {
//         await db.update(
//           'notisi',
//           {'content': color.withValues(red: 0.4).toString()},
//           where: 'title = ?',
//           whereArgs: [_fontColorTitle],
//         );
//       }
//     } catch (e, st) {
//       debugPrint('Failed to save font color to DB: $e\n$st');
//     }
//   }
// }
