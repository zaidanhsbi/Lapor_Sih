import 'package:flutter_dotenv/flutter_dotenv.dart';

  final String mapBoxToken = dotenv.env['MAPBOX_ACCES_TOKEN'] ?? '';
  final String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final String anonKey = dotenv.env['SUPABASE_PUBLISHABLE_OR_ANON_KEY'] ?? '';