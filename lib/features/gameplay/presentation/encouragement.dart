import '../domain/game_state.dart';

/// Original encouragement lines chosen from the current session state. Kept
/// deterministic so the message doesn't flicker on every rebuild.
abstract final class Encouragement {
  static const _start = "Let's crack this word!";
  static const _won = 'Brilliant work!';
  static const _lost = "So close — let's try again.";

  static const _afterCorrect = [
    'Nice choice!',
    "You're getting closer!",
    'Great letter!',
    'Keep it going!',
  ];

  static const _afterWrong = [
    'Try a different letter.',
    'Take another look at the clue.',
    'Hmm, not that one.',
    'Almost — think again!',
  ];

  static const _almost = 'Almost there!';

  static String forState(GameState state) {
    if (state.phase == GamePhase.won) return _won;
    if (state.phase == GamePhase.lost) return _lost;
    if (state.guessed.isEmpty) return _start;

    // If only one letter type remains hidden, nudge harder.
    final remaining = state.requiredLetters
        .where((l) => !state.guessed.contains(l))
        .length;
    if (remaining == 1) return _almost;

    final wrong = state.wrongCount;
    final correct = state.guessed.length - wrong;
    // Pick from a list using a stable index derived from guess counts.
    if (state.wrongLetters.length > correct) {
      return _afterWrong[wrong % _afterWrong.length];
    }
    return _afterCorrect[correct % _afterCorrect.length];
  }
}
