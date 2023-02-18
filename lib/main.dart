import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/color_schemes.g.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Open ObjectBox database
  objectbox = await ObjectBox.open();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List But Free',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          color: Color(0xFFD9FFEF),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
      ),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
