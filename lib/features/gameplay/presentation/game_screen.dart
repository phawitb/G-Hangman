import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/notebook_background.dart';
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
    _finishing = true;
    final level = _level!;
    final won = finalState.phase == GamePhase.won;
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
