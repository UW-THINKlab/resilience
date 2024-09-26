import 'dart:async';
import 'package:support_sphere/data/models/operational_event.dart';
import 'package:support_sphere/utils/supabase.dart';
import 'package:uuid/v4.dart';

class AppRepository {
  final _supabaseClient = supabase;

  Future<void> changeOperationalStatus({
    required String? operationalStatus,
  }) async {
    print("Changing operational status to $operationalStatus");
    await _supabaseClient.from('operational_events').insert({
      'id': const UuidV4().generate(),
      'created_by': _supabaseClient.auth.currentUser!.id,
      'created_at': DateTime.now().toIso8601String(),
      'status': operationalStatus,
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
            createdBy: record['created_by'],
            createdAt: record['created_at'],
            operationalStatus: record['status'],
          );
          return event;
        });
  }
}
