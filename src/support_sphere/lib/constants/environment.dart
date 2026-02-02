import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

final log = Logger('AppConfig');


/// Environment variables constants.
abstract class EnvironmentConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
}

// Need to fail over to file.
// See: https://medium.com/@tondawalkar.omkar/configuration-techniques-in-flutter-development-117bb6b836f6

const configFileName = 'assets/app_config.json';

//class AppConfigNotFoundError extends Error {}

class AppConfig {
  final String supabaseUrl;
  final String supabaseAnonKey;

  AppConfig({required this.supabaseUrl, required this.supabaseAnonKey});

  factory AppConfig.fromJson(String jsonString) {
    // Load the config file
    final Map<String, dynamic> data = json.decode(jsonString);
    final jsonUrl = data['supabaseUrl'];
    final jsonAnonKey = data['supabaseAnonKey'];

    log.fine('EnvironmentConfig.supabaseUrl: ${EnvironmentConfig.supabaseUrl}');
    log.fine('EnvironmentConfig.supabaseAnonKey: ${EnvironmentConfig.supabaseAnonKey.substring(0, 4)}...${EnvironmentConfig.supabaseAnonKey.substring(EnvironmentConfig.supabaseAnonKey.length - 4)}');


    final String supabaseUrl = EnvironmentConfig.supabaseUrl != '' ? EnvironmentConfig.supabaseUrl : jsonUrl;
    final String supabaseAnonKey = EnvironmentConfig.supabaseAnonKey != '' ? EnvironmentConfig.supabaseAnonKey : jsonAnonKey;

    log.fine('AppConfig - supabaseUrl: $supabaseUrl');
    log.fine('AppConfig - supabaseAnonKey: ${supabaseAnonKey.substring(0, 4)}...${supabaseAnonKey.substring(supabaseAnonKey.length - 4)}');

    return AppConfig(
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
    );
  }

  // Use the root bundle to load the app config settings
  static Future<AppConfig> loadBundle() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final String jsonStr = await rootBundle.loadString(configFileName);
      if (jsonStr.isEmpty) {
        throw Error();
      }
      final config = AppConfig.fromJson(jsonStr);
      return config;
    }
    catch (e, stackTrace) {
      log.severe('Error loading bundle: $e');
      log.severe('Trace: $stackTrace');
      throw Error();
    }
  }
}