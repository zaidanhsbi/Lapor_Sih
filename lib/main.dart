import 'package:flutter/material.dart';
import 'package:lapor_sih/login.dart';
import 'package:lapor_sih/register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Register(),
         debugShowCheckedModeBanner: false,
    ); 
  }
}