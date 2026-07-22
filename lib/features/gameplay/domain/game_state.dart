import '../../../core/constants/game_config.dart';
import '../../../core/utilities/word_utils.dart';
import 'game_level.dart';

/// Lifecycle phase of a single play session.
enum GamePhase { playing, won, lost }

/// Immutable snapshot of an in-progress guessing session.
///
/// This class holds *only* game logic — no coins, persistence, audio or UI.
/// That makes it trivial to unit-test and reuse across Adventure, Two-Player
/// and Daily modes.
class GameState {
  const GameState({
    required this.level,
    this.guessed = const <String>{},
    this.removedByHint = const <String>{},
    this.revealedByHint = const <String>{},
    this.extraChances = 0,
    this.revealHintCount = 0,
    this.removeHintCount = 0,
    this.paidHintUsed = false,
  });

  factory GameState.initial(GameLevel level) => GameState(level: level);

  final GameLevel level;

  /// Letters the player (or a reveal hint) has committed to. Upper-case.
  final Set<String> guessed;

  /// Wrong letters cleared from the keyboard by the "remove letters" hint.
  final Set<String> removedByHint;

  /// Correct letters injected by the "reveal letter" hint (subset of guessed).
  final Set<String> revealedByHint;

  /// Extra allowed mistakes bought via the Extra Chance hint.
  final int extraChances;

  final int revealHintCount;
  final int removeHintCount;

  /// True once any *paid* hint was used (affects 2-star eligibility).
  final bool paidHintUsed;

  // ---- Derived values -------------------------------------------------------

  Set<String> get requiredLetters => level.requiredLetters;

  int get maxMistakes => level.maxMistakes + extraChances;

  /// Letters that were guessed but are not in the answer.
  Set<String> get wrongLetters =>
      guessed.where((l) => !requiredLetters.contains(l)).toSet();

  int get wrongCount => wrongLetters.length;

  int get remainingMistakes => (maxMistakes - wrongCount).clamp(0, maxMistakes);

  bool get anyHintUsed =>
      revealHintCount > 0 || removeHintCount > 0 || extraChances > 0;

  bool get isSolved => WordUtils.isSolved(level.answer, guessed);

  bool get isFailed => wrongCount >= maxMistakes;

  GamePhase get phase {
    if (isSolved) return GamePhase.won;
    if (isFailed) return GamePhase.lost;
    return GamePhase.playing;
  }

  bool get isFinished => phase != GamePhase.playing;

  /// Masked characters for display (letters, separators, or null slots).
  List<String?> get maskedCharacters =>
      WordUtils.maskedCharacters(level.answer, guessed);

  /// A letter is [tappable] if it is still available on the keyboard.
  bool isLetterTappable(String letter) {
    final l = letter.toUpperCase();
    return !guessed.contains(l) && !removedByHint.contains(l);
  }

  bool isGuessed(String letter) => guessed.contains(letter.toUpperCase());

  bool isRemoved(String letter) => removedByHint.contains(letter.toUpperCase());

  bool isCorrectGuess(String letter) {
    final l = letter.toUpperCase();
    return guessed.contains(l) && requiredLetters.contains(l);
  }

  bool isWrongGuess(String letter) {
    final l = letter.toUpperCase();
    return guessed.contains(l) && !requiredLetters.contains(l);
  }

  /// Stars earned if the session were scored now.
  int get stars => GameConfig.starsFor(
    wrongGuesses: wrongCount,
    anyHintUsed: anyHintUsed,
    paidHintUsed: paidHintUsed,
  );

  /// Accuracy = correct guesses / total committed guesses (0–1).
  double get accuracy {
    if (guessed.isEmpty) return 1;
    final correct = guessed.where(requiredLetters.contains).length;
    return correct / guessed.length;
  }

  GameState copyWith({
    Set<String>? guessed,
    Set<String>? removedByHint,
    Set<String>? revealedByHint,
    int? extraChances,
    int? revealHintCount,
    int? removeHintCount,
    bool? paidHintUsed,
  }) {
    return GameState(
      level: level,
      guessed: guessed ?? this.guessed,
      removedByHint: removedByHint ?? this.removedByHint,
      revealedByHint: revealedByHint ?? this.revealedByHint,
      extraChances: extraChances ?? this.extraChances,
      revealHintCount: revealHintCount ?? this.revealHintCount,
      removeHintCount: removeHintCount ?? this.removeHintCount,
      paidHintUsed: paidHintUsed ?? this.paidHintUsed,
    );
  }
}
