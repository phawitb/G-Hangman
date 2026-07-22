import '../../../core/constants/game_config.dart';
import '../../../core/utilities/word_utils.dart';
import '../../gameplay/domain/difficulty.dart';
import '../../gameplay/domain/game_level.dart';

/// Validation + level construction for a Player-1 secret word.
abstract final class TwoPlayerWord {
  /// Returns an error message when [raw] is not a usable secret, else null.
  static String? validate(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'Please enter a secret word.';
    if (!RegExp(r"^[A-Za-z '\-]+$").hasMatch(trimmed)) {
      return 'Use letters, spaces and hyphens only.';
    }
    if (!WordUtils.hasGuessableLetter(trimmed)) {
      return 'The word needs at least one letter.';
    }
    final letters = WordUtils.normalize(
      trimmed,
    ).replaceAll(RegExp(r'[^A-Z]'), '');
    if (letters.length < GameConfig.twoPlayerMinWordLength) {
      return 'Make it at least ${GameConfig.twoPlayerMinWordLength} letters.';
    }
    if (letters.length > GameConfig.twoPlayerMaxWordLength) {
      return 'Keep it under ${GameConfig.twoPlayerMaxWordLength} letters.';
    }
    return null;
  }

  /// Builds a one-off [GameLevel] for the guessing player.
  static GameLevel buildLevel({
    required String secret,
    required String clue,
    required int maxMistakes,
  }) {
    final safeClue = clue.trim().isEmpty
        ? "Guess Player 1's secret word!"
        : clue.trim();
    return GameLevel(
      id: -1,
      category: 'Two Player',
      clue: safeClue,
      answer: WordUtils.normalize(secret),
      difficulty: Difficulty.medium,
      maxMistakes: maxMistakes.clamp(
        GameConfig.twoPlayerMinMistakes,
        GameConfig.twoPlayerMaxMistakes,
      ),
      coinReward: 0,
    );
  }
}
