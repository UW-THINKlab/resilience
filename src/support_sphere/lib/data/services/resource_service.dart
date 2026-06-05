import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/widgets.dart'; //debugPrint
import 'package:support_sphere/utils/supabase.dart';
import 'package:support_sphere/data/models/supplier_candidate.dart';

class ResourceService {
  final SupabaseClient _supabaseClient = supabase;

  Future<PostgrestList?> getUserResourcesByUserId(String userId) async {
    return await _supabaseClient.from('user_resources').select('''
      id,
      user_id,
      resources (
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
      ),
      quantity,
      notes,
      created_at,
      updated_at
    ''').eq('user_id', userId);
  }

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

  Future<PostgrestList?> getAllResources() async {
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
      ),
      user_resources (
        quantity
      )
    ''');
  }

  Future<void> addUserResource(Map<String, dynamic> data) async {
    await _supabaseClient.from('user_resources').upsert(data);
  }

  Future<void> deleteUserResource(String id) async {
    await _supabaseClient.from('user_resources').delete().eq('id', id);
  }

  Future<void> markUpToDate(String id, DateTime updatedAt) async {
    await _supabaseClient
        .from('user_resources')
        .update({'updated_at': updatedAt.toIso8601String()}).eq('id', id);
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

  Future<List<SupplierCandidate>> getNearestSuppliersByHousehold({
    required String requesterProfileId,
    required String resourceId,
  }) async {
    final result = await _supabaseClient.rpc(
      'get_nearest_resource_suppliers_by_household',
      params: {
        'p_requester_profile_id': requesterProfileId,
        'p_resource_id': resourceId,
      },
    );
    debugPrint('RPC raw data: $result');
    debugPrint('RPC type: ${result.runtimeType}');
    final rows = List<Map<String, dynamic>>.from(result as List);
    return rows.map(SupplierCandidate.fromJson).toList();
  }

  Future<List<SupplierCandidate>> getNearestSuppliersByCurrentLocation({
    required String requesterProfileId,
    required String resourceId,
    required double currentLatitude,
    required double currentLongitude,
  }) async {
    final result = await _supabaseClient.rpc(
      'get_nearest_resource_suppliers_by_current_location',
      params: {
        'p_requester_profile_id': requesterProfileId,
        'p_resource_id': resourceId,
        'p_latitude':
            currentLongitude, //TODO FIXME- HACK TO MATCH SWAPPED COORDINATES IN DB
        'p_longitude':
            currentLatitude, //TODO FIXME- HACK TO MATCH SWAPPED COORDINATES IN DB
      },
    );
    debugPrint(
        'WARNING: GEOMETRY IS FLIPPED IN DB, SO LAT/LON ARE SWAPPED IN THIS RPC CALL');
    debugPrint('RPC GEOM: $currentLatitude, $currentLongitude');
    debugPrint('RPC raw data: $result');
    debugPrint('RPC type: ${result.runtimeType}');
    final rows = List<Map<String, dynamic>>.from(result as List);
    return rows.map(SupplierCandidate.fromJson).toList();
  }

  Future<Map<String, dynamic>> createResourceRequest(
      Map<String, dynamic> data) async {
    final row =
        await _supabaseClient.from('requests').insert(data).select().single();

    return Map<String, dynamic>.from(row);
  }
}
