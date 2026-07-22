import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../features/settings/domain/app_settings.dart';
import 'key_value_store.dart';

/// Loads and saves [AppSettings] with tolerant defaults.
class SettingsRepository {
  SettingsRepository(this._store);

  static const String _key = 'dwq.settings.v1';
  final KeyValueStore _store;

  AppSettings load() {
    final raw = _store.getString(_key);
    if (raw == null || raw.isEmpty) return AppSettings.initial();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return AppSettings.fromJson(decoded);
    } catch (e) {
      debugPrint('SettingsRepository: failed to decode settings ($e).');
    }
    return AppSettings.initial();
  }

  Future<void> save(AppSettings settings) async {
    try {
      await _store.setString(_key, jsonEncode(settings.toJson()));
    } catch (e) {
      debugPrint('SettingsRepository: failed to save settings ($e).');
    }
  }

  Future<void> reset() => _store.remove(_key);
}
