import 'app_language.dart';

/// Persisted locale selection. [chosen] gates the first-launch language screen.
class LocaleState {
  const LocaleState({required this.language, required this.chosen});

  factory LocaleState.initial() =>
      const LocaleState(language: AppLanguage.english, chosen: false);

  final AppLanguage language;
  final bool chosen;

  LocaleState copyWith({AppLanguage? language, bool? chosen}) => LocaleState(
    language: language ?? this.language,
    chosen: chosen ?? this.chosen,
  );
}
