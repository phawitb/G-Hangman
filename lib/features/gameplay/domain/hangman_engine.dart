import '../../../core/constants/economy.dart';
import '../../../core/utilities/word_utils.dart';
import 'game_state.dart';
import 'hint_type.dart';

/// Pure, side-effect-free reducers over [GameState].
///
/// Every method returns a *new* state; nothing here touches coins, storage,
/// audio or the UI, which is what makes the game logic fully unit-testable.
abstract final class HangmanEngine {
  static const String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  /// Commit a letter guess. No-op when the game is finished, the input is not a
  /// letter, or the letter is unavailable (prevents duplicate guesses).
  static GameState guess(GameState state, String rawLetter) {
    if (state.isFinished) return state;
    final letter = rawLetter.toUpperCase();
    if (!WordUtils.isLetter(letter)) return state;
    if (!state.isLetterTappable(letter)) return state;
    return state.copyWith(guessed: {...state.guessed, letter});
  }

  /// Letters still available on the keyboard.
  static List<String> availableLetters(GameState state) => alphabet
      .split('')
      .where((l) => state.isLetterTappable(l))
      .toList(growable: false);

  // ---- Reveal-letter hint ---------------------------------------------------

  static bool canReveal(GameState state) =>
      !state.isFinished && _nextRevealTarget(state) != null;

  static String? _nextRevealTarget(GameState state) {
    for (final ch in state.level.normalizedAnswer.split('')) {
      if (WordUtils.isLetter(ch) && !state.guessed.contains(ch)) return ch;
    }
    return null;
  }

  static GameState revealLetter(GameState state) {
    final target = _nextRevealTarget(state);
    if (target == null) return state;
    return state.copyWith(
      guessed: {...state.guessed, target},
      revealedByHint: {...state.revealedByHint, target},
      revealHintCount: state.revealHintCount + 1,
      paidHintUsed: true,
    );
  }

  // ---- Remove-letters hint --------------------------------------------------

  /// Wrong, still-available letters that could be cleared.
  static List<String> removableLetters(GameState state) => alphabet
      .split('')
      .where(
        (l) =>
            !state.level.requiredLetters.contains(l) &&
            !state.guessed.contains(l) &&
            !state.removedByHint.contains(l),
      )
      .toList(growable: false);

  static bool canRemove(GameState state) =>
      !state.isFinished && removableLetters(state).isNotEmpty;

  static GameState removeLetters(GameState state) {
    final candidates = removableLetters(state);
    if (candidates.isEmpty) return state;
    final toRemove = candidates.take(Economy.removeLettersCount).toSet();
    return state.copyWith(
      removedByHint: {...state.removedByHint, ...toRemove},
      removeHintCount: state.removeHintCount + 1,
      paidHintUsed: true,
    );
  }

  // ---- Extra-chance hint ----------------------------------------------------

  static bool canExtraChance(GameState state) =>
      !state.isFinished && state.extraChances < Economy.maxExtraChancePerLevel;

  static GameState extraChance(GameState state) {
    if (!canExtraChance(state)) return state;
    return state.copyWith(
      extraChances: state.extraChances + 1,
      paidHintUsed: true,
    );
  }

  /// Whether a given hint can currently do something useful (ignores coins).
  static bool canApply(GameState state, HintType hint) => switch (hint) {
    HintType.revealLetter => canReveal(state),
    HintType.removeLetters => canRemove(state),
    HintType.extraChance => canExtraChance(state),
  };

  static GameState apply(GameState state, HintType hint) => switch (hint) {
    HintType.revealLetter => revealLetter(state),
    HintType.removeLetters => removeLetters(state),
    HintType.extraChance => extraChance(state),
  };
}
