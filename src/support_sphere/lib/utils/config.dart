import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/constants/environment.dart';

class Config {
  static initSupabase() async {
    await Supabase.initialize(
        url: EnvironmentConfig.supabaseUrl, anonKey: EnvironmentConfig.supabaseAnonKey,
        headers: {'Access-Control-Allow-Origin': '*'});
  }
}
