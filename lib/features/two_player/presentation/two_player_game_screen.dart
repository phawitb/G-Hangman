import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/notebook_background.dart';
import '../../gameplay/application/game_controller.dart';
import '../../gameplay/application/game_mode.dart';
import '../../gameplay/domain/game_level.dart';
import '../../gameplay/domain/game_state.dart';
import '../../gameplay/presentation/game_play_view.dart';
import '../../localization/application/locale_controller.dart';
import '../../localization/domain/str_key.dart';
import '../../results/domain/result_args.dart';

/// Player 2 guesses the secret word. No coins/hints or progression here.
class TwoPlayerGameScreen extends ConsumerStatefulWidget {
  const TwoPlayerGameScreen({super.key, required this.level});

  final GameLevel level;

  @override
  ConsumerState<TwoPlayerGameScreen> createState() =>
      _TwoPlayerGameScreenState();
}

class _TwoPlayerGameScreenState extends ConsumerState<TwoPlayerGameScreen> {
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    // Defer provider mutation until after the first frame (see GameScreen).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(gameControllerProvider.notifier)
            .start(widget.level, mode: GameMode.twoPlayer);
      }
    });
  }

  Future<void> _onFinish(GameState finalState) async {
    if (_finishing) return;
    _finishing = true;
    await Future.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    context.go(
      AppRoutes.result,
      extra: ResultArgs(
        mode: GameMode.twoPlayer,
        level: widget.level,
        finalState: finalState,
        coinsEarned: 0,
      ),
    );
  }

  Future<void> _confirmLeave() async {
    final state = ref.read(gameControllerProvider);
    if (state?.phase != GamePhase.playing) {
      if (mounted) context.go(AppRoutes.home);
      return;
    }
    final t = ref.read(translateProvider);
    final leave = await showDoodleConfirm(
      context,
      title: t(StrKey.leaveTitle),
      message: t(StrKey.leaveMessage),
      confirmLabel: t(StrKey.leave),
      cancelLabel: t(StrKey.stay),
      destructive: true,
    );
    if (leave && mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translateProvider);
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
            title: t(StrKey.playerTwoTurn),
            onBack: _confirmLeave,
          ),
        ),
      ),
    );
  }
}
