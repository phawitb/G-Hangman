import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/economy.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/notebook_background.dart';
import '../../gameplay/application/game_controller.dart';
import '../../gameplay/application/game_mode.dart';
import '../../gameplay/domain/game_level.dart';
import '../../gameplay/domain/game_state.dart';
import '../../gameplay/presentation/game_play_view.dart';
import '../../progression/application/progress_controller.dart';
import '../../results/domain/result_args.dart';
import '../application/daily_controller.dart';
import '../domain/daily_challenge.dart';

/// Daily challenge: one deterministic level per calendar day.
class DailyScreen extends ConsumerStatefulWidget {
  const DailyScreen({super.key});

  @override
  ConsumerState<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends ConsumerState<DailyScreen> {
  late final GameLevel _level;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    final levels = ref.read(levelRepositoryProvider).all;
    _level = DailyChallenge.forDate(DateTime.now(), levels);
    // Defer provider mutation until after the first frame (see GameScreen).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(gameControllerProvider.notifier)
            .start(_level, mode: GameMode.daily);
      }
    });
  }

  Future<void> _onFinish(GameState finalState) async {
    if (_finishing) return;
    _finishing = true;
    final won = finalState.phase == GamePhase.won;
    var coinsEarned = 0;
    if (won) {
      final newly = await ref
          .read(dailyControllerProvider.notifier)
          .completeToday(DateTime.now());
      if (newly) {
        await ref
            .read(progressControllerProvider.notifier)
            .addCoins(Economy.dailyRewardCoins);
        coinsEarned = Economy.dailyRewardCoins;
      }
    }
    if (!mounted) return;
    final streak = ref.read(dailyControllerProvider).currentStreak;
    await Future.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    context.go(
      AppRoutes.result,
      extra: ResultArgs(
        mode: GameMode.daily,
        level: _level,
        finalState: finalState,
        coinsEarned: coinsEarned,
        dailyStreak: streak,
      ),
    );
  }

  Future<void> _confirmLeave() async {
    final state = ref.read(gameControllerProvider);
    if (state?.phase != GamePhase.playing) {
      if (mounted) context.go(AppRoutes.home);
      return;
    }
    final leave = await showDoodleConfirm(
      context,
      title: 'Leave the daily challenge?',
      message: 'You can come back and finish it any time today.',
      confirmLabel: 'Leave',
      cancelLabel: 'Stay',
      destructive: true,
    );
    if (leave && mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
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
          child: GamePlayView(title: 'Daily Challenge', onBack: _confirmLeave),
        ),
      ),
    );
  }
}
