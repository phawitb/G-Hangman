import '../../../core/constants/game_config.dart';
import '../../../core/utilities/word_utils.dart';
import '../../gameplay/domain/difficulty.dart';
import '../../gameplay/domain/game_level.dart';

/// Reasons a Player-1 secret word can be rejected (mapped to localized text by
/// the UI).
enum TwoPlayerError { empty, chars, needsLetter, tooShort, tooLong }

/// Validation + level construction for a Player-1 secret word.
abstract final class TwoPlayerWord {
  static final RegExp _allowed = RegExp(r"^[A-Za-zÅÄÖÜåäöü '\-]+$");

  /// Returns an error reason when [raw] is not a usable secret, else null.
  static TwoPlayerError? validate(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return TwoPlayerError.empty;
    if (!_allowed.hasMatch(trimmed)) return TwoPlayerError.chars;
    if (!WordUtils.hasGuessableLetter(trimmed)) {
      return TwoPlayerError.needsLetter;
    }
    final letters = WordUtils.normalize(
      trimmed,
    ).replaceAll(RegExp(r'[^A-ZÅÄÖÜ]'), '');
    if (letters.length < GameConfig.twoPlayerMinWordLength) {
      return TwoPlayerError.tooShort;
    }
    if (letters.length > GameConfig.twoPlayerMaxWordLength) {
      return TwoPlayerError.tooLong;
    }
    return null;
  }

  /// Builds a one-off [GameLevel] for the guessing player.
  static GameLevel buildLevel({
    required String secret,
    required String clue,
    required int maxMistakes,
    required String category,
    required String defaultClue,
    required String alphabet,
  }) {
    final safeClue = clue.trim().isEmpty ? defaultClue : clue.trim();
    return GameLevel(
      id: -1,
      category: category,
      clue: safeClue,
      answer: WordUtils.normalize(secret),
      difficulty: Difficulty.medium,
      maxMistakes: maxMistakes.clamp(
        GameConfig.twoPlayerMinMistakes,
        GameConfig.twoPlayerMaxMistakes,
      ),
      coinReward: 0,
      alphabet: alphabet,
    );
  }
}
