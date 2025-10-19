import 'package:flutter/material.dart';
import 'package:lapor_sih/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
    try {
    await dotenv.load(fileName: ".env");
    print('✅ dotenv loaded');
  } catch (e) {
    print('❌ dotenv error: $e');
  }

   final String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final String anonKey = dotenv.env['SUPABASE_PUBLISHABLE_OR_ANON_KEY'] ?? '';


  print('✅ URL: $supabaseUrl');
  print('✅ ANON: ${anonKey}');
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: anonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    ); 
  }
} 