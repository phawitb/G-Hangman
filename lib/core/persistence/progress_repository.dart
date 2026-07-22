import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../features/progression/domain/player_progress.dart';
import 'key_value_store.dart';

/// Loads and saves [PlayerProgress], keyed by language code so each language
/// keeps its own progress. Corrupt or missing data yields the initial progress.
class ProgressRepository {
  ProgressRepository(this._store);

  static const String _base = 'dwq.progress.v1';
  final KeyValueStore _store;

  String _keyFor(String languageCode) => '$_base.$languageCode';

  PlayerProgress load(String languageCode) {
    final raw = _store.getString(_keyFor(languageCode));
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

  Future<void> save(String languageCode, PlayerProgress progress) async {
    try {
      await _store.setString(
        _keyFor(languageCode),
        jsonEncode(progress.toJson()),
      );
    } catch (e) {
      debugPrint('ProgressRepository: failed to save progress ($e).');
    }
  }

  Future<void> reset(String languageCode) =>
      _store.remove(_keyFor(languageCode));
}
