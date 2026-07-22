import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/economy.dart';
import '../../../core/providers.dart';
import '../domain/level_record.dart';
import '../domain/play_result.dart';
import '../domain/player_progress.dart';

final progressControllerProvider =
    NotifierProvider<ProgressController, PlayerProgress>(
      ProgressController.new,
    );

class ProgressController extends Notifier<PlayerProgress> {
  final Random _random = Random();

  /// Small consolation reward for replaying an already-completed level, so
  /// coins can't be farmed indefinitely at full value.
  static const int _replayReward = 5;

  @override
  PlayerProgress build() => ref.watch(progressRepositoryProvider).load();

  Future<void> _persist(PlayerProgress next) async {
    state = next;
    await ref.read(progressRepositoryProvider).save(next);
  }

  // ---- Coins ---------------------------------------------------------------

  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    await _persist(state.copyWith(coins: state.coins + amount));
  }

  /// Attempts to spend [amount]; returns false (and changes nothing) when the
  /// balance is insufficient, so a balance can never go negative.
  Future<bool> spendCoins(int amount) async {
    if (amount <= 0) return true;
    if (state.coins < amount) return false;
    await _persist(state.copyWith(coins: state.coins - amount));
    return true;
  }

  // ---- Recording results ---------------------------------------------------

  /// Applies a finished Adventure play. Returns the coins awarded for the play.
  Future<int> recordResult(PlayResult result) async {
    if (result.won) {
      return _recordWin(result);
    } else {
      await _recordLoss(result);
      return 0;
    }
  }

  Future<int> _recordWin(PlayResult result) async {
    final existing = state.recordFor(result.levelId);
    final firstClear = existing == null || !existing.isCompleted;
    final wasPerfect = existing?.perfect ?? false;

    final coinsEarned = firstClear ? result.baseCoinReward : _replayReward;

    final updatedRecord = LevelRecord(
      levelId: result.levelId,
      stars: max(existing?.stars ?? 0, result.stars),
      bestAccuracy: max(existing?.bestAccuracy ?? 0, result.accuracy),
      perfect: wasPerfect || result.isPerfect,
      timesPlayed: (existing?.timesPlayed ?? 0) + 1,
    );

    final newRecords = {...state.records, result.levelId: updatedRecord};

    // Unlock the next level if we just cleared the current frontier.
    var unlocked = state.unlockedLevelId;
    if (result.levelId >= state.unlockedLevelId) {
      final next = ref.read(levelRepositoryProvider).nextAfter(result.levelId);
      if (next != null) unlocked = next.id;
    }

    final newStreak = state.currentStreak + 1;
    final newPerfectCount = (result.isPerfect && !wasPerfect)
        ? state.perfectCount + 1
        : state.perfectCount;
    final newWinsTowardChest = min(
      state.winsTowardChest + 1,
      Economy.winsPerChest,
    );

    await _persist(
      state.copyWith(
        coins: state.coins + coinsEarned,
        records: newRecords,
        unlockedLevelId: unlocked,
        currentStreak: newStreak,
        longestStreak: max(state.longestStreak, newStreak),
        perfectCount: newPerfectCount,
        winsTowardChest: newWinsTowardChest,
      ),
    );

    return coinsEarned;
  }

  Future<void> _recordLoss(PlayResult result) async {
    final existing = state.recordFor(result.levelId);
    final updatedRecord =
        (existing ??
                LevelRecord(
                  levelId: result.levelId,
                  stars: 0,
                  bestAccuracy: 0,
                  perfect: false,
                  timesPlayed: 0,
                ))
            .copyWith(timesPlayed: (existing?.timesPlayed ?? 0) + 1);

    await _persist(
      state.copyWith(
        records: {...state.records, result.levelId: updatedRecord},
        currentStreak: 0,
      ),
    );
  }

  // ---- Reward chest --------------------------------------------------------

  /// Opens the chest when ready, returning the coins granted. Returns 0 (and
  /// changes nothing) when the chest is not ready, preventing double-collect.
  Future<int> openChest() async {
    if (!state.chestReady) return 0;
    final reward =
        Economy.chestRewardMin +
        _random.nextInt(Economy.chestRewardMax - Economy.chestRewardMin + 1);
    await _persist(
      state.copyWith(
        coins: state.coins + reward,
        winsTowardChest: state.winsTowardChest - Economy.winsPerChest,
        chestsOpened: state.chestsOpened + 1,
      ),
    );
    return reward;
  }

  // ---- Reset ---------------------------------------------------------------

  Future<void> resetAll() async {
    await ref.read(progressRepositoryProvider).reset();
    await _persist(PlayerProgress.initial());
  }
}
