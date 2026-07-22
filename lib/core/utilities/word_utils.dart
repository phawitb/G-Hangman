/// Helpers for normalising answers and comparing guessed letters.
///
/// Rules:
///  * comparison is case-insensitive (everything upper-cased);
///  * spaces, punctuation and hyphens are treated as fixed separators that are
///    always shown and never need to be guessed;
///  * only ASCII letters A–Z count as "guessable".
abstract final class WordUtils {
  static final RegExp _letter = RegExp(r'[A-Z]');

  /// Upper-cases and trims a raw answer for storage/comparison.
  static String normalize(String raw) => raw.trim().toUpperCase();

  /// Returns true if [char] is a guessable letter (A–Z).
  static bool isLetter(String char) =>
      char.length == 1 && _letter.hasMatch(char.toUpperCase());

  /// The distinct set of letters that must be revealed to win [answer].
  static Set<String> requiredLetters(String answer) {
    final result = <String>{};
    for (final ch in normalize(answer).split('')) {
      if (isLetter(ch)) result.add(ch);
    }
    return result;
  }

  /// True when every required letter of [answer] is contained in [guessed].
  static bool isSolved(String answer, Set<String> guessed) {
    final upper = guessed.map((e) => e.toUpperCase()).toSet();
    return requiredLetters(answer).every(upper.contains);
  }

  /// Builds the display characters for the masked word.
  ///
  /// Each entry is either the revealed character, a separator (space/punct.),
  /// or `null` for a not-yet-guessed letter slot.
  static List<String?> maskedCharacters(String answer, Set<String> guessed) {
    final upper = guessed.map((e) => e.toUpperCase()).toSet();
    final chars = normalize(answer).split('');
    return chars.map<String?>((ch) {
      if (!isLetter(ch)) return ch; // separator, always shown
      return upper.contains(ch) ? ch : null;
    }).toList();
  }

  /// Whether the answer contains at least one guessable letter.
  static bool hasGuessableLetter(String answer) =>
      requiredLetters(answer).isNotEmpty;
}
