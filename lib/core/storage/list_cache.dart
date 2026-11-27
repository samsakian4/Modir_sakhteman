import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Offline-first helper: stores the last successful list response as JSON and
/// serves it back when the network is unavailable (doc 21 — offline first).
abstract class ListCache {
  ListCache._();

  static bool _looksOffline(Object e) {
    final String t = e.toString().toLowerCase();
    return t.contains('socket') || t.contains('network') || t.contains('timeout') || t.contains('failed host lookup') || t.contains('clientexception') || t.contains('failed to fetch');
  }

  static Future<List<Map<String, dynamic>>> fetch({
    required String box,
    required String key,
    required Future<List<Map<String, dynamic>>> Function() remote,
    bool useCache = true,
  }) async {
    if (!useCache) return remote();
    try {
      final List<Map<String, dynamic>> rows = await remote();
      await _save(box, key, rows);
      return rows;
    } catch (e) {
      if (_looksOffline(e)) {
        final List<Map<String, dynamic>>? cached = _load(box, key);
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  static Future<void> _save(String box, String key, List<Map<String, dynamic>> rows) async {
    try {
      if (Hive.isBoxOpen(box)) await Hive.box<Map>(box).put(key, {'json': jsonEncode(rows)});
    } catch (_) {}
  }

  static List<Map<String, dynamic>>? _load(String box, String key) {
    try {
      if (!Hive.isBoxOpen(box)) return null;
      final Map? stored = Hive.box<Map>(box).get(key);
      if (stored == null) return null;
      return (jsonDecode(stored['json'] as String) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }
}
