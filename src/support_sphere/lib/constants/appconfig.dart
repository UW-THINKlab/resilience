import 'package:latlong2/latlong.dart' show LatLng;

// INTENTION: AppConfig _instance should be generated with a specific build script, from config.

class AppConfig {
  static const String neighborhood = "ZZZZZ Laurelhurst";
  static const LatLng location = LatLng(47.658, -122.277);
  static const String supabaseUrl = "http://laurelhurst.supportsphere.acmerocket.com";
  static const String supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzI2NTU2NDAwLAogICJleHAiOiAxODg0MzIyODAwCn0.mAQE_wTdAytVXk6DKkm2tPFXRGmNrMw72sldwdXZGEo";
}