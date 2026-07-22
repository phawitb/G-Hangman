/// Non-economy gameplay rules, kept configurable in one place.
abstract final class GameConfig {
  /// Default allowed wrong guesses when a level does not specify its own.
  static const int defaultMaxMistakes = 6;

  /// Two-player defaults.
  static const int twoPlayerDefaultMistakes = 6;
  static const int twoPlayerMinMistakes = 3;
  static const int twoPlayerMaxMistakes = 10;
  static const int twoPlayerMinWordLength = 3;
  static const int twoPlayerMaxWordLength = 18;

  /// Star thresholds (configurable).
  ///
  /// * 3 stars — zero wrong guesses AND no hints used.
  /// * 2 stars — at most [twoStarMaxMistakes] wrong guesses AND no paid hint.
  /// * 1 star — completed otherwise.
  static const int twoStarMaxMistakes = 2;

  /// A "perfect" completion (used for the Perfects counter) mirrors 3 stars.
  static int starsFor({
    required int wrongGuesses,
    required bool anyHintUsed,
    required bool paidHintUsed,
  }) {
    if (wrongGuesses == 0 && !anyHintUsed) return 3;
    if (wrongGuesses <= twoStarMaxMistakes && !paidHintUsed) return 2;
    return 1;
  }
}
