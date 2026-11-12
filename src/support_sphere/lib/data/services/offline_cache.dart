import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support_sphere/utils/supabase.dart';

final _log = Logger('OfflineCache');

/// Keeps the last successful result of read queries on the device, so screens
/// can show saved data when Supabase is unreachable.
///
/// Entries are raw query results (JSON), stored per signed-in user under
/// [prefix]. A query falls back to its saved copy only on network failures;
/// a [PostgrestException] means the server answered, so it is rethrown.
class OfflineCache {
  static const prefix = 'offline_cache:v1:';

  /// How long to wait for the network before using the saved copy. A link
  /// with no upstream (e.g. a mesh node without backhaul) can hang for minutes.
  static Duration timeout = const Duration(seconds: 10);

  /// After a network failure, reads with a saved copy skip the network for
  /// this long, so a screen that makes several queries doesn't wait out a
  /// timeout for each one.
  static Duration retryAfter = const Duration(seconds: 30);

  /// Who the saved data belongs to; reads aren't cached without a user.
  @visibleForTesting
  static String? Function() currentUserId =
      () => supabase.auth.currentUser?.id;

  /// When the oldest saved data on screen was fetched, while the app is
  /// showing saved data because the network is unreachable; null otherwise.
  static final ValueNotifier<DateTime?> showingSavedSince = ValueNotifier(null);

  /// The latest write that failed because the network is unreachable.
  static final ValueNotifier<Object?> lastFailedWrite = ValueNotifier(null);

  static DateTime? _offlineUntil;

  /// Whether [error] means the server couldn't be reached (as opposed to the
  /// server rejecting the request).
  static bool isNetworkError(Object error) => error is! PostgrestException;

  /// Runs [query] and saves its result under [key]; if the network is
  /// unreachable, returns the result saved last time instead.
  static Future<T> fetch<T>(
    String key,
    Future<T> Function() query, {
    required T Function(dynamic json) decode,
  }) async {
    final storageKey = _storageKey(key);
    if (storageKey == null) return query();

    final offline =
        _offlineUntil != null && DateTime.now().isBefore(_offlineUntil!);
    if (offline) {
      final saved = await _read(storageKey);
      if (saved != null) return _useSaved(saved, decode);
    }

    final T result;
    try {
      result = await query().timeout(timeout);
    } catch (error) {
      if (!isNetworkError(error)) rethrow;
      _offlineUntil = DateTime.now().add(retryAfter);
      final saved = await _read(storageKey);
      if (saved == null) rethrow;
      _log.info('Network unreachable; using saved "$key"', error);
      return _useSaved(saved, decode);
    }
    markOnline();
    await _write(storageKey, result);
    return result;
  }

  /// Saves [data] under [key] without a query (e.g. a realtime stream value).
  static Future<void> save(String key, Object? data) async {
    final storageKey = _storageKey(key);
    if (storageKey != null) await _write(storageKey, data);
  }

  /// The data saved under [key], with when it was saved.
  static Future<({dynamic data, DateTime savedAt})?> load(String key) async {
    final storageKey = _storageKey(key);
    return storageKey == null ? null : _read(storageKey);
  }

  /// Records that saved data from [savedAt] is on screen because the network
  /// is unreachable.
  static void markShowingSaved(DateTime savedAt) {
    final current = showingSavedSince.value;
    if (current == null || savedAt.isBefore(current)) {
      showingSavedSince.value = savedAt;
    }
  }

  /// Records that the server answered, so data on screen is current again.
  static void markOnline() {
    _offlineUntil = null;
    showingSavedSince.value = null;
  }

  /// Reports a write that failed; network failures are surfaced to the user.
  /// Returns whether [error] was a network failure.
  static bool reportWriteError(Object error) {
    if (!isNetworkError(error)) return false;
    lastFailedWrite.value = error;
    return true;
  }

  /// Deletes every user's saved data. Call before signing out: on a shared
  /// device the next person must not see it.
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in prefs.getKeys().where((k) => k.startsWith(prefix))) {
        await prefs.remove(key);
      }
    } catch (error) {
      _log.warning('Could not clear saved data', error);
    }
    markOnline();
  }

  static String? _storageKey(String key) {
    final userId = currentUserId();
    return userId == null ? null : '$prefix$userId:$key';
  }

  static T _useSaved<T>(
    ({dynamic data, DateTime savedAt}) saved,
    T Function(dynamic json) decode,
  ) {
    markShowingSaved(saved.savedAt);
    return decode(saved.data);
  }

  static Future<({dynamic data, DateTime savedAt})?> _read(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null) return null;
      final entry = jsonDecode(raw) as Map<String, dynamic>;
      return (data: entry['d'], savedAt: DateTime.parse(entry['t']));
    } catch (error) {
      _log.warning('Could not read saved "$key"', error);
      return null;
    }
  }

  static Future<void> _write(String key, Object? data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        key,
        jsonEncode({'t': DateTime.now().toIso8601String(), 'd': data}),
      );
    } catch (error) {
      // Storage full or unavailable: the app still works, just not offline.
      _log.warning('Could not save "$key"', error);
    }
  }
}

/// Decodes a saved list of rows.
List<Map<String, dynamic>> decodeRows(dynamic json) =>
    (json as List).cast<Map<String, dynamic>>();

/// Decodes a saved single row, which may be null.
Map<String, dynamic>? decodeRow(dynamic json) =>
    json as Map<String, dynamic>?;
