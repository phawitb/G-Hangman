import 'package:doodle_word_quest/core/persistence/key_value_store.dart';
import 'package:doodle_word_quest/core/providers.dart';
import 'package:doodle_word_quest/features/daily/application/daily_controller.dart';
import 'package:doodle_word_quest/features/daily/domain/daily_challenge.dart';
import 'package:doodle_word_quest/features/progression/application/progress_controller.dart';
import 'package:doodle_word_quest/features/progression/domain/play_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer _container() {
  final container = ProviderContainer(
    overrides: [
      keyValueStoreProvider.overrideWithValue(InMemoryKeyValueStore()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

PlayResult _win(int levelId, {int reward = 20, int stars = 3}) => PlayResult(
  levelId: levelId,
  won: true,
  stars: stars,
  accuracy: 1,
  wrongGuesses: 0,
  baseCoinReward: reward,
  paidHintUsed: false,
);

void main() {
  group('ProgressController', () {
    test('recording a win awards coins, unlocks next, grows streak', () async {
      final c = _container();
      final controller = c.read(progressControllerProvider.notifier);
      final before = c.read(progressControllerProvider).coins;

      final earned = await controller.recordResult(_win(1, reward: 20));

      final p = c.read(progressControllerProvider);
      expect(earned, 20);
      expect(p.coins, before + 20);
      expect(p.unlockedLevelId, 2);
      expect(p.currentStreak, 1);
      expect(p.winsTowardChest, 1);
      expect(p.starsFor(1), 3);
      expect(p.perfectCount, 1);
    });

    test('losing resets the streak', () async {
      final c = _container();
      final controller = c.read(progressControllerProvider.notifier);
      await controller.recordResult(_win(1));
      await controller.recordResult(
        const PlayResult(
          levelId: 2,
          won: false,
          stars: 0,
          accuracy: 0,
          wrongGuesses: 6,
          baseCoinReward: 20,
          paidHintUsed: false,
        ),
      );
      expect(c.read(progressControllerProvider).currentStreak, 0);
    });

    test('replaying a cleared level gives only a small reward', () async {
      final c = _container();
      final controller = c.read(progressControllerProvider.notifier);
      await controller.recordResult(_win(1, reward: 20));
      final second = await controller.recordResult(_win(1, reward: 20));
      expect(second, lessThan(20));
    });

    test('cannot spend more coins than owned', () async {
      final c = _container();
      final controller = c.read(progressControllerProvider.notifier);
      final start = c.read(progressControllerProvider).coins;
      final ok = await controller.spendCoins(start + 1);
      expect(ok, isFalse);
      expect(c.read(progressControllerProvider).coins, start);
    });

    test('chest opens only when ready and pays coins', () async {
      final c = _container();
      final controller = c.read(progressControllerProvider.notifier);
      expect(await controller.openChest(), 0); // not ready yet

      for (var i = 1; i <= 5; i++) {
        await controller.recordResult(_win(i));
      }
      expect(c.read(progressControllerProvider).chestReady, isTrue);
      final coinsBefore = c.read(progressControllerProvider).coins;
      final reward = await controller.openChest();
      expect(reward, greaterThan(0));
      expect(c.read(progressControllerProvider).coins, coinsBefore + reward);
      expect(c.read(progressControllerProvider).chestReady, isFalse);
      // Cannot double-collect immediately.
      expect(await controller.openChest(), 0);
    });

    test('resetAll returns to the initial state', () async {
      final c = _container();
      final controller = c.read(progressControllerProvider.notifier);
      await controller.recordResult(_win(1));
      await controller.resetAll();
      final p = c.read(progressControllerProvider);
      expect(p.unlockedLevelId, 1);
      expect(p.completedCount, 0);
    });
  });

  group('DailyChallenge selection', () {
    test('is deterministic for a given date', () {
      final c = _container();
      final levels = c.read(levelRepositoryProvider).all;
      final a = DailyChallenge.forDate(DateTime(2026, 5, 20), levels);
      final b = DailyChallenge.forDate(DateTime(2026, 5, 20), levels);
      expect(a.id, b.id);
    });
  });

  group('DailyController streak', () {
    test('increments across consecutive days, resets on a gap', () async {
      final c = _container();
      final controller = c.read(dailyControllerProvider.notifier);
      final day1 = DateTime(2026, 1, 1);
      final day2 = DateTime(2026, 1, 2);
      final day4 = DateTime(2026, 1, 4);

      expect(await controller.completeToday(day1), isTrue);
      expect(c.read(dailyControllerProvider).currentStreak, 1);

      // Same day again does not re-count.
      expect(await controller.completeToday(day1), isFalse);
      expect(c.read(dailyControllerProvider).currentStreak, 1);

      expect(await controller.completeToday(day2), isTrue);
      expect(c.read(dailyControllerProvider).currentStreak, 2);

      // Gap of a day resets to 1.
      expect(await controller.completeToday(day4), isTrue);
      expect(c.read(dailyControllerProvider).currentStreak, 1);
      expect(c.read(dailyControllerProvider).longestStreak, 2);
    });
  });
}
