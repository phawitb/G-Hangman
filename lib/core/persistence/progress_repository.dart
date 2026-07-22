import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../features/progression/domain/player_progress.dart';
import 'key_value_store.dart';

/// Loads and saves [PlayerProgress]. Corrupt or missing data yields the initial
/// progress instead of throwing.
class ProgressRepository {
  ProgressRepository(this._store);

  static const String _key = 'dwq.progress.v1';
  final KeyValueStore _store;

  PlayerProgress load() {
    final raw = _store.getString(_key);
    if (raw == null || raw.isEmpty) return PlayerProgress.initial();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return PlayerProgress.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('ProgressRepository: failed to decode progress ($e).');
    }
    return PlayerProgress.initial();
  }

  Future<void> save(PlayerProgress progress) async {
    try {
      await _store.setString(_key, jsonEncode(progress.toJson()));
    } catch (e) {
      debugPrint('ProgressRepository: failed to save progress ($e).');
    }
  }

  Future<void> reset() => _store.remove(_key);
}
