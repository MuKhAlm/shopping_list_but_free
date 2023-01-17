import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Open ObjectBox databse
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
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
