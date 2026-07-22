import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'dart:async';

import '../../../app/routes.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/notebook_background.dart';
import '../../ads/application/ad_providers.dart';
import '../../ads/domain/ad_reward.dart';
import '../../progression/application/progress_controller.dart';
import '../../progression/domain/play_result.dart';
import '../../results/domain/result_args.dart';
import '../application/game_controller.dart';
import '../application/game_mode.dart';
import '../domain/game_level.dart';
import '../domain/game_state.dart';
import 'game_play_view.dart';
import 'invalid_level_view.dart';

/// Adventure-mode wrapper: starts a session for [levelId], persists the result
/// and routes to the result screen when the session ends.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.levelId});

  final int levelId;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  GameLevel? _level;
  bool _invalid = false;
  bool _finishing = false;
  bool _reviveOffered = false;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(levelRepositoryProvider);
    final level = repo.byId(widget.levelId);
    final unlocked = ref
        .read(progressControllerProvider)
        .isUnlocked(widget.levelId);
    if (level == null || !unlocked) {
      _invalid = true;
      return;
    }
    _level = level;
    // Defer starting the session until after this frame: mutating a provider
    // synchronously during initState (which runs inside the route's build) is
    // not allowed by Riverpod.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(gameControllerProvider.notifier)
            .start(level, mode: GameMode.adventure);
      }
    });
  }

  Future<void> _onFinish(GameState finalState) async {
    if (_finishing) return;
    final level = _level!;
    final won = finalState.phase == GamePhase.won;

    // Offer a one-time "watch an ad to keep playing" revive before finalising a
    // loss. If the player revives, the session returns to playing and we bail
    // out without recording anything.
    if (!won && !_reviveOffered) {
      _reviveOffered = true;
      final revived = await _offerRevive();
      if (revived || !mounted) return;
    }

    _finishing = true;

    if (won) {
      // Feed the interstitial cadence; the ad itself is shown between levels
      // from the result screen, never during gameplay.
      ref.read(adServiceProvider).registerLevelCompleted();
    }

    final result = PlayResult(
      levelId: level.id,
      won: won,
      stars: won ? finalState.stars : 0,
      accuracy: finalState.accuracy,
      wrongGuesses: finalState.wrongCount,
      baseCoinReward: level.coinReward,
      paidHintUsed: finalState.paidHintUsed,
    );
    final coinsEarned = await ref
        .read(progressControllerProvider.notifier)
        .recordResult(result);
    if (!mounted) return;

    // Small pause so the win/lose scene animation is visible.
    await Future.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;

    final next = ref.read(levelRepositoryProvider).nextAfter(level.id);
    context.go(
      AppRoutes.result,
      extra: ResultArgs(
        mode: GameMode.adventure,
        level: level,
        finalState: finalState,
        coinsEarned: coinsEarned,
        nextLevelId: next?.id,
      ),
    );
  }

  /// Offers a rewarded-ad revive. Returns true only if the ad was watched to
  /// completion (reward earned) and the session was brought back to life.
  Future<bool> _offerRevive() async {
    final adService = ref.read(adServiceProvider);
    // Only tempt the player when an ad is actually ready to show.
    if (!adService.isRewardedReady) return false;

    final accepted = await showDoodleConfirm(
      context,
      title: 'Out of chances!',
      message:
          'Watch a short ad to get ${AdRewards.reviveExtraChances} more '
          'guesses and keep this level going?',
      confirmLabel: 'Watch ad',
      cancelLabel: 'No thanks',
    );
    if (!accepted || !mounted) return false;

    var earned = false;
    final done = Completer<void>();
    await adService.showRewarded(
      onReward: () => earned = true,
      onUnavailable: () {
        if (!done.isCompleted) done.complete();
      },
      onClosed: () {
        if (!done.isCompleted) done.complete();
      },
    );
    await done.future;
    if (!earned || !mounted) return false;

    return ref
        .read(gameControllerProvider.notifier)
        .revive(AdRewards.reviveExtraChances);
  }

  Future<void> _confirmLeave() async {
    final state = ref.read(gameControllerProvider);
    final playing = state?.phase == GamePhase.playing;
    if (!playing) {
      if (mounted) context.go(AppRoutes.levels);
      return;
    }
    final leave = await showDoodleConfirm(
      context,
      title: 'Leave this level?',
      message: 'Your progress on this word will be lost.',
      confirmLabel: 'Leave',
      cancelLabel: 'Stay',
      destructive: true,
    );
    if (leave && mounted) context.go(AppRoutes.levels);
  }

  @override
  Widget build(BuildContext context) {
    if (_invalid) {
      return const InvalidLevelView();
    }

    // Route to the result screen once the session finishes.
    ref.listen<GameState?>(gameControllerProvider, (prev, next) {
      if (next != null && next.isFinished && !_finishing) {
        _onFinish(next);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        body: NotebookBackground(
          child: GamePlayView(
            title: 'Level ${widget.levelId}',
            onBack: _confirmLeave,
          ),
        ),
      ),
    );
  }
}
