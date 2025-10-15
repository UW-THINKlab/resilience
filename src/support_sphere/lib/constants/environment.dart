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