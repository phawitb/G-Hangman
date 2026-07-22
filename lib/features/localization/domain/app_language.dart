/// The languages the game supports. Each carries its own guessable alphabet
/// (including the Nordic/German extra letters) so gameplay and keyboards adapt.
enum AppLanguage {
  english('en', 'English', 'English', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'),
  german('de', 'German', 'Deutsch', 'ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜ'),
  swedish('sv', 'Swedish', 'Svenska', 'ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ'),
  finnish('fi', 'Finnish', 'Suomi', 'ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ');

  const AppLanguage(
    this.code,
    this.englishName,
    this.nativeName,
    this.alphabet,
  );

  /// ISO code used for persistence keys.
  final String code;

  /// Name in English (for accessibility / reference).
  final String englishName;

  /// Name in the language itself (shown on the picker).
  final String nativeName;

  /// Ordered set of guessable upper-case letters for this language.
  final String alphabet;

  List<String> get letters => alphabet.split('');

  static AppLanguage fromCode(String? code) {
    for (final lang in AppLanguage.values) {
      if (lang.code == code) return lang;
    }
    return AppLanguage.english;
  }
}
