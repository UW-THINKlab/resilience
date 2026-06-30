import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';
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

class AppConfig {
  static late AppConfig? _instance;

  static AppConfig get instance {
    return _instance!;
  }

  final String neighborhood;
  final LatLng location;
  final String supabaseUrl;
  final String supabaseAnonKey;

  AppConfig({required this.neighborhood, required this.location, required this.supabaseUrl, required this.supabaseAnonKey});

  factory AppConfig.fromJson(String jsonString) {
    // Load the config file
    final Map<String, dynamic> data = json.decode(jsonString);
    final jsonUrl = data['supabaseUrl'];
    final jsonAnonKey = data['supabaseAnonKey'];
    final neighborhood = data['neighborhood'];
    final location =  LatLng.fromJson(data['location']);

    // Prefer EnvironmentConfig (envvar) over json
    final String supabaseUrl = EnvironmentConfig.supabaseUrl != '' ? EnvironmentConfig.supabaseUrl : jsonUrl;
    final String supabaseAnonKey = EnvironmentConfig.supabaseAnonKey != '' ? EnvironmentConfig.supabaseAnonKey : jsonAnonKey;
    // TODO Copy for neighborhood and location? Or  remove?

    log.fine('AppConfig - supabaseUrl: $supabaseUrl');
    log.fine('AppConfig - supabaseAnonKey: ${supabaseAnonKey.substring(0, 4)}...${supabaseAnonKey.substring(supabaseAnonKey.length - 4)}');

    return AppConfig(
      neighborhood: neighborhood,
      location: location,
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
    );
  }

  // Use the root bundle to load the app config settings
  static Future<AppConfig> loadBundle() async {
    if (_instance != null) {
      return _instance!;
    }
    // otherwise, load the data from the rootBundle
    try {
      WidgetsFlutterBinding.ensureInitialized();

      // Load app_config
      final String jsonStr = await rootBundle.loadString(configFileName);
      if (jsonStr.isEmpty) {
        throw Error();
      }
      _instance = AppConfig.fromJson(jsonStr);
      return _instance!;
    }
    catch (e, stackTrace) {
      log.severe('Error loading bundle: $e');
      log.severe('Trace: $stackTrace');
      throw Error();
    }
  }
}
