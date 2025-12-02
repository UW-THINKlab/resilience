import 'package:logging/logging.dart' show Logger;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/constants/environment.dart';

final log = Logger('Config');

class Config {
  static Future<void> initSupabase() async {
    log.config("Loading config bundle...");
    final AppConfig config = await AppConfig.loadBundle();

    log.config("Initializing supabase: ${config.supabaseUrl}");
    await Supabase.initialize(
      url: config.supabaseUrl,
      anonKey: config.supabaseAnonKey,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, content-type, x-client-info, apikey',
      }
    );
    log.config("Supabase initialization complete.");
  }
}
