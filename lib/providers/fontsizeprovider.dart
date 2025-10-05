// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import 'package:notibuku/services/note_services.dart';

// final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
//   return FontSizeNotifier();
// });

// class FontSizeNotifier extends StateNotifier<double> {
//   static const String _fontSizeTitle = 'fontSize';
//   FontSizeNotifier() : super(20.0) {
//     _loadFontSize();
//   }

//   Future<void> _loadFontSize() async {
//     try {
//       final db = await DatabaseService.instance.database;
//       final List<Map<String, dynamic>> results = await db.query(
//         'notisi',
//         where: 'title = ?',
//         whereArgs: [_fontSizeTitle],
//       );
//       if (results.isNotEmpty) {
//         final content = results.first['content'] as String? ?? '';
//         final loadedSize = double.tryParse(content);
//         if (loadedSize != null) {
//           state = loadedSize;
//         }
//       }
//     } catch (e, st) {
//       debugPrint('Failed to load font size from DB: $e\n$st');
//     }
//   }

//   Future<void> setFontSize(double size) async {
//     state = size;
//     try {
//       final db = await DatabaseService.instance.database;
//       // Check if setting exists
//       final existing = await db.query(
//         'notisi',
//         where: 'title = ?',
//         whereArgs: [_fontSizeTitle],
//       );
//       if (existing.isEmpty) {
//         // Insert new record
//         await db.insert('notisi', {
//           'title': _fontSizeTitle,
//           'content': size.toString(),
//         });
//       } else {
//         // Update existing record
//         await db.update(
//           'notisi',
//           {'content': size.toString()},
//           where: 'title = ?',
//           whereArgs: [_fontSizeTitle],
//         );
//       }
//     } catch (e, st) {
//       debugPrint('Failed to save font size to DB: $e\n$st');
//     }
//   }
// }
