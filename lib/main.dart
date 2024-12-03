import 'package:flutter/material.dart';
import 'package:tour_management_app/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tour Management App',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
