import 'package:shared_preferences/shared_preferences.dart';

/// Minimal key/value persistence contract. Keeping repositories behind this
/// interface lets tests inject [InMemoryKeyValueStore] with no plugin channel.
abstract interface class KeyValueStore {
  String? getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
  Future<void> clear();
}

/// Production implementation backed by `shared_preferences`.
class SharedPrefsKeyValueStore implements KeyValueStore {
  SharedPrefsKeyValueStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<SharedPrefsKeyValueStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPrefsKeyValueStore(prefs);
  }

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);

  @override
  Future<void> clear() => _prefs.clear();
}

/// In-memory implementation for unit tests.
class InMemoryKeyValueStore implements KeyValueStore {
  InMemoryKeyValueStore([Map<String, String>? seed]) : _data = {...?seed};

  final Map<String, String> _data;

  @override
  String? getString(String key) => _data[key];

  @override
  Future<void> setString(String key, String value) async => _data[key] = value;

  @override
  Future<void> remove(String key) async => _data.remove(key);

  @override
  Future<void> clear() async => _data.clear();
}
