import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const PicToContactApp());
}

class PicToContactApp extends StatelessWidget {
  const PicToContactApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
