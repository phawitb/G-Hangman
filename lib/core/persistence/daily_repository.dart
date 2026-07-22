import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../features/daily/domain/daily_state.dart';
import 'key_value_store.dart';

/// Loads and saves [DailyState] with tolerant defaults.
class DailyRepository {
  DailyRepository(this._store);

  static const String _key = 'dwq.daily.v1';
  final KeyValueStore _store;

  DailyState load() {
    final raw = _store.getString(_key);
    if (raw == null || raw.isEmpty) return DailyState.initial();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return DailyState.fromJson(decoded);
    } catch (e) {
      debugPrint('DailyRepository: failed to decode daily state ($e).');
    }
    return DailyState.initial();
  }

  Future<void> save(DailyState state) async {
    try {
      await _store.setString(_key, jsonEncode(state.toJson()));
    } catch (e) {
      debugPrint('DailyRepository: failed to save daily state ($e).');
    }
  }

  Future<void> reset() => _store.remove(_key);
}
