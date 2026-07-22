import '../../features/localization/domain/app_language.dart';
import '../../features/localization/domain/locale_state.dart';
import 'key_value_store.dart';

/// Persists the chosen language and whether the first-launch pick happened.
class LocaleRepository {
  LocaleRepository(this._store);

  static const String _codeKey = 'dwq.locale.code';
  static const String _chosenKey = 'dwq.locale.chosen';
  final KeyValueStore _store;

  LocaleState load() {
    final code = _store.getString(_codeKey);
    final chosen = _store.getString(_chosenKey) == 'true';
    if (code == null) return LocaleState.initial();
    return LocaleState(language: AppLanguage.fromCode(code), chosen: chosen);
  }

  Future<void> save(LocaleState state) async {
    await _store.setString(_codeKey, state.language.code);
    await _store.setString(_chosenKey, state.chosen ? 'true' : 'false');
  }

  Future<void> reset() async {
    await _store.remove(_codeKey);
    await _store.remove(_chosenKey);
  }
}
