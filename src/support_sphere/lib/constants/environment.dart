/// Environment variables constants.
abstract class EnvironmentConstants {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'http://localhost',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-super-secret-jwt-token-with-at-least-32-characters-long',
  );
}