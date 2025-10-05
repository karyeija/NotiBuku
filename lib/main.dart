import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notibuku/pages/notes_page.dart';

void main() async {
  // Initialize the database and insert users
  WidgetsFlutterBinding.ensureInitialized();

  // await DatabaseService.instance.initializeUsers();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Notebook',
      theme: ThemeData(
        appBarTheme: AppBarThemeData(backgroundColor: Colors.green[400]),
        useMaterial3: true,
        useSystemColors: true,
      ),
      home: NoteList(),
    );
  }
}
