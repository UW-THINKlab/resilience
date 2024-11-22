import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/utils/supabase.dart';

class ResourceService {
  final SupabaseClient _supabaseClient = supabase;

  Future<PostgrestList?> getResourceCVByText(String text) async {
    return await _supabaseClient.from('resources_cv').select('''
      id,
      name,
      description
    ''').ilike('name', '%$text%');
  }

  Future<PostgrestList?> getResourceTypes() async {
    return await _supabaseClient.from('resource_types').select('''
      id,
      name
    ''');
  }

  Future<PostgrestList?> getResources() async {
    return await _supabaseClient.from('resources').select('''
      notes,
      qty_needed,
      qty_available,
      resources_cv (
        id,
        name,
        description
      ),
      resource_types (
        id,
        name,
        description
      )
    ''');
  }

  Future<void> createResourceCV(Map<String, dynamic> data) async {
    await _supabaseClient.from('resources_cv').upsert(data);
  }

  Future<void> createResource(Map<String, dynamic> data) async {
    await _supabaseClient.from('resources').upsert(data);
  }

  Future<void> deleteResource(String id) async {
    await _supabaseClient.from('resources').delete().eq('resource_cv_id', id);
  }

  Future<void> deleteResourceCV(String id) async {
    await _supabaseClient.from('resources_cv').delete().eq('id', id);
  }
}