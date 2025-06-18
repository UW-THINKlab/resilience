import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/constants/environment.dart';

class Config {
  static Future<void> initSupabase() async {
    await Supabase.initialize(
        url: EnvironmentConfig.supabaseUrl, anonKey: EnvironmentConfig.supabaseAnonKey,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': 'authorization, content-type, x-client-info, apikey',
          }
          );
  }
}
