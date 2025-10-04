import 'package:airshield/constants.dart';
import 'package:airshield/pages/welcome.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: colorFondo,
        primaryColor: colorFuerte,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(secondary: colorTexto),
      ),
      debugShowCheckedModeBanner: false,
      home: Welcome(),
    );
  }
}
