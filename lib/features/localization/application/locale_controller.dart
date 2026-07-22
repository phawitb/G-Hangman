import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/locale_repository.dart';
import '../../../core/providers.dart';
import '../domain/app_language.dart';
import '../domain/locale_state.dart';
import '../domain/str_key.dart';
import '../domain/app_strings.dart';

final localeRepositoryProvider = Provider<LocaleRepository>(
  (ref) => LocaleRepository(ref.watch(keyValueStoreProvider)),
);

final localeControllerProvider =
    NotifierProvider<LocaleController, LocaleState>(LocaleController.new);

class LocaleController extends Notifier<LocaleState> {
  @override
  LocaleState build() => ref.watch(localeRepositoryProvider).load();

  AppLanguage get language => state.language;

  Future<void> _persist(LocaleState next) async {
    state = next;
    await ref.read(localeRepositoryProvider).save(next);
  }

  /// First-launch pick: sets the language and marks the choice as made.
  Future<void> choose(AppLanguage language) =>
      _persist(LocaleState(language: language, chosen: true));

  /// Change language later (from Settings), keeping the chosen flag.
  Future<void> setLanguage(AppLanguage language) =>
      _persist(state.copyWith(language: language));
}

/// A translator bound to the current language.
typedef Translate = String Function(StrKey key, [Map<String, Object>? params]);

/// Convenience translator provider — `ref.watch(translateProvider)` rebuilds
/// widgets when the language changes.
final translateProvider = Provider<Translate>((ref) {
  final lang = ref.watch(localeControllerProvider).language;
  return (StrKey key, [Map<String, Object>? params]) =>
      AppStrings.tr(lang, key, params);
});
