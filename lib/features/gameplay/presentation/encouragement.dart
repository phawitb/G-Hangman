import '../../localization/domain/str_key.dart';
import '../domain/game_state.dart';

/// Picks an encouragement string key from the current session state. The UI
/// translates the key, so the message follows the selected language.
abstract final class Encouragement {
  static StrKey forState(GameState state) {
    if (state.phase == GamePhase.won) return StrKey.encWon;
    if (state.phase == GamePhase.lost) return StrKey.encLost;
    if (state.guessed.isEmpty) return StrKey.encStart;

    final remaining = state.requiredLetters
        .where((l) => !state.guessed.contains(l))
        .length;
    if (remaining == 1) return StrKey.encAlmost;

    final wrong = state.wrongCount;
    final correct = state.guessed.length - wrong;
    if (state.wrongLetters.length > correct) return StrKey.encTryAnother;
    return StrKey.encNice;
  }
}
