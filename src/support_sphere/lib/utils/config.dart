import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/constants/environment.dart';

class Config {
  static initSupabase() async {
    await Supabase.initialize(
        url: EnvironmentConstants.supabaseUrl, anonKey: EnvironmentConstants.supabaseAnnonKey);
  }
}
