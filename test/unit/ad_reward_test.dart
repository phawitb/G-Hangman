import 'package:doodle_word_quest/core/persistence/key_value_store.dart';
import 'package:doodle_word_quest/core/providers.dart';
import 'package:doodle_word_quest/features/ads/application/ad_service.dart';
import 'package:doodle_word_quest/features/ads/application/noop_ad_service.dart';
import 'package:doodle_word_quest/features/ads/domain/ad_reward.dart';
import 'package:doodle_word_quest/features/gameplay/application/game_controller.dart';
import 'package:doodle_word_quest/features/gameplay/application/game_mode.dart';
import 'package:doodle_word_quest/features/gameplay/domain/difficulty.dart';
import 'package:doodle_word_quest/features/gameplay/domain/game_level.dart';
import 'package:doodle_word_quest/features/gameplay/domain/game_state.dart';
import 'package:doodle_word_quest/features/progression/application/progress_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake ad service that simulates the earn/unavailable outcomes so reward
/// wiring can be tested without the native SDK.
class FakeAdService implements AdService {
  FakeAdService({this.willEarn = true, this.available = true});

  bool willEarn;
  bool available;
  int rewardedShown = 0;

  @override
  bool get canRequestAds => true;
  @override
  bool get isRewardedReady => available;
  @override
  bool get isInterstitialReady => false;
  @override
  bool get isPrivacyOptionsRequired => false;

  @override
  Future<void> showRewarded({
    required VoidCallback onReward,
    VoidCallback? onUnavailable,
    VoidCallback? onClosed,
  }) async {
    rewardedShown++;
    if (!available) {
      onUnavailable?.call();
      onClosed?.call();
      return;
    }
    // Reward is granted ONLY when the user earned it.
    if (willEarn) onReward();
    onClosed?.call();
  }

  @override
  Future<void> initialize() async {}
  @override
  void preloadRewarded() {}
  @override
  void preloadInterstitial() {}
  @override
  void registerLevelCompleted() {}
  @override
  Future<bool> maybeShowInterstitial() async => false;
  @override
  Future<void> showPrivacyOptions() async {}
  @override
  void dispose() {}
}

const _level = GameLevel(
  id: 1,
  category: 'Test',
  clue: 'c',
  answer: 'BOOK',
  difficulty: Difficulty.easy,
  maxMistakes: 3,
);

ProviderContainer _container() {
  final c = ProviderContainer(
    overrides: [
      keyValueStoreProvider.overrideWithValue(InMemoryKeyValueStore()),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('rewarded coin grant', () {
    test('grants coins only when the reward is earned', () async {
      final c = _container();
      final progress = c.read(progressControllerProvider.notifier);
      final before = c.read(progressControllerProvider).coins;

      final ad = FakeAdService(willEarn: true);
      await ad.showRewarded(
        onReward: () => progress.addCoins(AdRewards.coinAmount),
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        c.read(progressControllerProvider).coins,
        before + AdRewards.coinAmount,
      );
    });

    test(
      'does not grant coins when the ad is dismissed without earning',
      () async {
        final c = _container();
        final progress = c.read(progressControllerProvider.notifier);
        final before = c.read(progressControllerProvider).coins;

        final ad = FakeAdService(willEarn: false);
        var unavailable = false;
        await ad.showRewarded(
          onReward: () => progress.addCoins(AdRewards.coinAmount),
          onUnavailable: () => unavailable = true,
        );

        expect(c.read(progressControllerProvider).coins, before);
        expect(unavailable, isFalse); // it showed, user just didn't earn
      },
    );

    test('reports unavailable and grants nothing with no inventory', () async {
      final c = _container();
      final progress = c.read(progressControllerProvider.notifier);
      final before = c.read(progressControllerProvider).coins;

      final ad = FakeAdService(available: false);
      var unavailable = false;
      await ad.showRewarded(
        onReward: () => progress.addCoins(AdRewards.coinAmount),
        onUnavailable: () => unavailable = true,
      );

      expect(unavailable, isTrue);
      expect(c.read(progressControllerProvider).coins, before);
    });

    test('NoopAdService never earns a reward', () async {
      var granted = false;
      var unavailable = false;
      await NoopAdService().showRewarded(
        onReward: () => granted = true,
        onUnavailable: () => unavailable = true,
      );
      expect(granted, isFalse);
      expect(unavailable, isTrue);
    });
  });

  group('GameController ad rewards', () {
    test(
      'revealLetterFromAd reveals a letter without spending coins',
      () async {
        final c = _container();
        final coinsBefore = c.read(progressControllerProvider).coins;
        final game = c.read(gameControllerProvider.notifier);
        game.start(_level, mode: GameMode.adventure);

        final revealed = await game.revealLetterFromAd();

        expect(revealed, isTrue);
        final state = c.read(gameControllerProvider)!;
        expect(state.guessed, isNotEmpty);
        expect(c.read(progressControllerProvider).coins, coinsBefore);
      },
    );

    test(
      'revive brings a lost game back to playing with more chances',
      () async {
        final c = _container();
        final game = c.read(gameControllerProvider.notifier);
        game.start(_level, mode: GameMode.adventure);

        // Lose: BOOK needs B,O,K; guess three wrong letters (max 3).
        for (final l in ['X', 'Y', 'Z']) {
          await game.guess(l);
        }
        expect(c.read(gameControllerProvider)!.phase, GamePhase.lost);

        final ok = await game.revive(AdRewards.reviveExtraChances);
        expect(ok, isTrue);
        final revived = c.read(gameControllerProvider)!;
        expect(revived.phase, GamePhase.playing);
        expect(revived.remainingMistakes, AdRewards.reviveExtraChances);
      },
    );

    test('revive does nothing when the game is not lost', () async {
      final c = _container();
      final game = c.read(gameControllerProvider.notifier);
      game.start(_level, mode: GameMode.adventure);
      expect(await game.revive(2), isFalse);
    });
  });
}
