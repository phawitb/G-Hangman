import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/haptics/haptics_service.dart';
import '../../../core/providers.dart';
import '../../progression/application/progress_controller.dart';
import '../domain/game_level.dart';
import '../domain/game_state.dart';
import '../domain/hangman_engine.dart';
import '../domain/hint_type.dart';
import 'game_mode.dart';

/// Holds the single active play session. `null` until [start] is called.
final gameControllerProvider = NotifierProvider<GameController, GameState?>(
  GameController.new,
);

class GameController extends Notifier<GameState?> {
  GameMode _mode = GameMode.adventure;
  bool _coinsEnabled = true;

  @override
  GameState? build() => null;

  GameMode get mode => _mode;
  bool get coinsEnabled => _coinsEnabled;

  AudioService get _audio => ref.read(audioServiceProvider);
  HapticsService get _haptics => ref.read(hapticsServiceProvider);

  /// Begins a fresh session for [level].
  void start(GameLevel level, {GameMode mode = GameMode.adventure}) {
    _mode = mode;
    _coinsEnabled = mode.coinsEnabled;
    state = GameState.initial(level);
  }

  /// Restarts the current level from scratch.
  void restart() {
    final current = state;
    if (current != null) start(current.level, mode: _mode);
  }

  /// Commit a letter guess with feedback.
  Future<void> guess(String letter) async {
    final current = state;
    if (current == null || current.isFinished) return;
    final next = HangmanEngine.guess(current, letter);
    if (identical(next, current) ||
        next.guessed.length == current.guessed.length) {
      return; // duplicate / invalid — no state change
    }
    state = next;

    if (next.isCorrectGuess(letter)) {
      await _audio.play(SoundEvent.correct);
      await _haptics.trigger(HapticEvent.selection);
    } else {
      await _audio.play(SoundEvent.wrong);
      await _haptics.trigger(HapticEvent.warning);
    }

    if (next.phase == GamePhase.won) {
      await _audio.play(SoundEvent.win);
      await _haptics.trigger(HapticEvent.success);
    } else if (next.phase == GamePhase.lost) {
      await _audio.play(SoundEvent.lose);
      await _haptics.trigger(HapticEvent.heavy);
    }
  }

  /// Attempt to apply a hint. Handles coin cost, availability and feedback.
  Future<HintOutcome> useHint(HintType hint) async {
    final current = state;
    if (current == null || current.isFinished) return HintOutcome.nothingToDo;

    if (!HangmanEngine.canApply(current, hint)) {
      // Distinguish "extra chance already maxed" from "nothing to reveal".
      if (hint == HintType.extraChance) return HintOutcome.alreadyUsedMax;
      return HintOutcome.nothingToDo;
    }

    if (_coinsEnabled) {
      final progress = ref.read(progressControllerProvider.notifier);
      final paid = await progress.spendCoins(hint.cost);
      if (!paid) return HintOutcome.notEnoughCoins;
    }

    state = HangmanEngine.apply(current, hint);
    await _audio.play(SoundEvent.hint);
    await _haptics.trigger(HapticEvent.light);
    return HintOutcome.applied;
  }

  /// Reveals one correct letter for free (granted by a rewarded ad). Returns
  /// true when a letter was revealed. Does not touch coins.
  Future<bool> revealLetterFromAd() async {
    final current = state;
    if (current == null || !HangmanEngine.canReveal(current)) return false;
    state = HangmanEngine.revealLetter(current);
    await _audio.play(SoundEvent.hint);
    await _haptics.trigger(HapticEvent.light);
    return true;
  }

  /// Whether a one-time revive is possible: the session is lost but reviving
  /// with extra chances would let the player keep going.
  bool get canRevive {
    final current = state;
    return current != null && current.phase == GamePhase.lost;
  }

  /// Brings a lost session back to life by adding a few extra chances
  /// (granted by a rewarded ad). Returns true when the revive succeeded.
  Future<bool> revive(int extraChances) async {
    final current = state;
    if (current == null || current.phase != GamePhase.lost) return false;
    // Add enough extra chances that at least [extraChances] mistakes remain.
    final deficit = current.wrongCount - current.level.maxMistakes;
    final added = deficit + extraChances;
    state = current.copyWith(extraChances: current.extraChances + added);
    await _haptics.trigger(HapticEvent.success);
    return true;
  }
}
