// ignore_for_file: deprecated_member_use, package_api_docs, public_member_api_docs
import 'package:flutter/material.dart';
import 'home_view.dart';
void main() => runApp(const MyApp());



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      themeMode: ThemeMode.light,
      home: HomeView(),
    );
  }
}