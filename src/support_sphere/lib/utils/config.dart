import 'package:logging/logging.dart' show Logger;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/constants/appconfig.dart';

final log = Logger('Config');

class Config {
  static Future<void> initSupabase() async {
    log.config("Initializing supabase: ${AppConfig.supabaseUrl}");
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, content-type, x-client-info, apikey',
      }
    );
    log.config("Supabase initialization complete.");
  }
}
