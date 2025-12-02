import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

final log = Logger('AppConfig');


/// Environment variables constants.
abstract class EnvironmentConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'ANON_KEY',
    defaultValue: 'soMe-SuperlongAnonKey',
  );
}

// Need to fail over to file.
// See: https://medium.com/@tondawalkar.omkar/configuration-techniques-in-flutter-development-117bb6b836f6

const configFileName = 'assets/app_config.json';

class AppConfigNotFoundError extends Error {}

class AppConfig {
  final String supabaseUrl;
  final String supabaseAnonKey;

  AppConfig({required this.supabaseUrl, required this.supabaseAnonKey});

  factory AppConfig.fromJson(String jsonString) {
    // TODO - Check env.
    final Map<String, dynamic> data = json.decode(jsonString);
    return AppConfig(
      supabaseUrl: data['supabaseUrl'],
      supabaseAnonKey: data['supabaseAnonKey'],
    );
  }

  // Use the root bundle to load the app config settings
  static Future<AppConfig> loadBundle() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final String jsonStr = await rootBundle.loadString(configFileName);
      if (jsonStr.isEmpty) {
        throw AppConfigNotFoundError();
      }
      final config = AppConfig.fromJson(jsonStr);
      return config;
    }
    catch (e, stackTrace) {
      log.severe('Error loading bundle: $e');
      log.severe('Trace: $stackTrace');
      throw AppConfigNotFoundError();
    }
  }
}