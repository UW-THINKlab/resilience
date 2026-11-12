import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:support_sphere/data/services/offline_cache.dart';

void main() {
  String? userId;

  Future<List<Map<String, dynamic>>> rows(String name) async => [
        {'name': name, 'nested': {'a': [1, 2]}}
      ];
  Future<List<Map<String, dynamic>>> unreachable() async =>
      throw Exception('Failed host lookup');

  Future<List<Map<String, dynamic>>> fetch(
    Future<List<Map<String, dynamic>>> Function() query,
  ) =>
      OfflineCache.fetch('rows', query, decode: decodeRows);

  setUp(() {
    SharedPreferences.setMockInitialValues({'sb-session': 'keep me'});
    userId = 'user-a';
    OfflineCache.currentUserId = () => userId;
    OfflineCache.timeout = const Duration(milliseconds: 50);
    OfflineCache.retryAfter = Duration.zero;
    OfflineCache.markOnline();
  });

  test('returns live data and clears the offline state', () async {
    OfflineCache.markShowingSaved(DateTime(2026));
    expect(await fetch(() => rows('live')), [
      {'name': 'live', 'nested': {'a': [1, 2]}}
    ]);
    expect(OfflineCache.showingSavedSince.value, isNull);
  });

  test('falls back to saved data on a network error', () async {
    await fetch(() => rows('saved'));
    final result = await fetch(unreachable);
    expect(result.single['name'], 'saved');
    expect(result.single['nested'], {'a': [1, 2]});
    expect(OfflineCache.showingSavedSince.value, isNotNull);
  });

  test('falls back to saved data when the network hangs', () async {
    await fetch(() => rows('saved'));
    final result = await fetch(() => Completer<List<Map<String, dynamic>>>().future);
    expect(result.single['name'], 'saved');
  });

  test('rethrows server errors instead of using saved data', () async {
    await fetch(() => rows('saved'));
    expect(
      fetch(() async => throw const PostgrestException(message: 'denied')),
      throwsA(isA<PostgrestException>()),
    );
  });

  test('rethrows a network error when nothing was saved', () async {
    expect(fetch(unreachable), throwsException);
  });

  test('keeps a saved null distinct from nothing saved', () async {
    Future<Map<String, dynamic>?> row(Future<Map<String, dynamic>?> Function() q) =>
        OfflineCache.fetch('row', q, decode: decodeRow);
    await row(() async => null);
    expect(await row(() async => throw Exception('offline')), isNull);
  });

  test('skips the network for a while after a failure', () async {
    OfflineCache.retryAfter = const Duration(minutes: 1);
    await fetch(() => rows('saved'));
    await fetch(unreachable);
    var called = false;
    final result = await fetch(() {
      called = true;
      return rows('live');
    });
    expect(called, isFalse);
    expect(result.single['name'], 'saved');
  });

  test("doesn't show one user's saved data to another", () async {
    await fetch(() => rows('a'));
    userId = 'user-b';
    expect(fetch(unreachable), throwsException);
  });

  test('clear removes saved data but keeps other preferences', () async {
    await fetch(() => rows('saved'));
    await OfflineCache.save('operational_status', 'emergency');
    await OfflineCache.clear();
    expect(fetch(unreachable), throwsException);
    expect(await OfflineCache.load('operational_status'), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('sb-session'), 'keep me');
  });

  test('without a signed-in user, queries run uncached', () async {
    userId = null;
    expect(await fetch(() => rows('live')), hasLength(1));
    expect(fetch(unreachable), throwsException);
  });
}
