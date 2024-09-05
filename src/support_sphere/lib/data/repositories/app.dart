import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/data/models/operational_event.dart';
import 'package:support_sphere/utils/supabase.dart';
import 'package:uuid/v4.dart';

class AppRepository {
  final _supabaseClient = supabase;

  // Stream<Map> get mode {
  //   // Transform the regular supabase user object to our own User model
  //   return getOperationalStatus();
  // }

  Future<void> changeOperationalStatus({
    required String? operational_status,
  }) async {
    print("Changing operational status to $operational_status");
    await _supabaseClient.from('operational_events').insert({
      'id': UuidV4().generate(),
      'created_by': _supabaseClient.auth.currentUser!.id,
      'created_at': DateTime.now().toIso8601String(),
      'status': operational_status,
    });
  }


  Stream<OperationalEvent> get operationalStatus {
    return _supabaseClient
        .from('operational_events')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(1)
        .map((data) {
          Map<String, dynamic> record = data[0];
          // Parse the data into a OperationalEvent object
          OperationalEvent event = OperationalEvent(
            id: record['id'],
            created_by: record['created_by'],
            created_at: record['created_at'],
            operational_status: record['status'],
          );
          return event;
        });
  }
}
