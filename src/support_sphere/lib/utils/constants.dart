import 'package:flutter/material.dart';

/// Environment variables and shared app constants.
abstract class Constants {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'http://localhost',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-super-secret-jwt-token-with-at-least-32-characters-long',
  );
}

/// Color constants used in the app
abstract class ColorConstants {
  static const Color seed = Color.fromARGB(255, 14, 54, 70);
  static const Color transparent = Color.fromARGB(0, 0, 0, 0);
}
