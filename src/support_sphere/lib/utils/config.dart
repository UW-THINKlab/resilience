import 'package:logging/logging.dart' show Logger;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/constants/environment.dart';

final _log = Logger('Config');

class Config {
  static Future<void> initSupabase() async {
    final url = EnvironmentConfig.supabaseUrl;
    _log.config("Initializing supabase: $url");
    await Supabase.initialize(
        url: url,
        anonKey: EnvironmentConfig.supabaseAnonKey,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': 'authorization, content-type, x-client-info, apikey',
        }
      );
  }
}
