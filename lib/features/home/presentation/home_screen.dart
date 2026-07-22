import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/doodle_colors.dart';
import '../../../app/theme/doodle_metrics.dart';
import '../../../app/theme/doodle_text_styles.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/character_scene.dart';
import '../../../core/widgets/coin_counter.dart';
import '../../../core/widgets/doodle_button.dart';
import '../../../core/widgets/doodle_icon_button.dart';
import '../../../core/widgets/doodle_icons.dart';
import '../../../core/widgets/notebook_background.dart';
import '../../gameplay/domain/scene_theme.dart';
import '../../gameplay/domain/game_state.dart';
import '../../progression/application/progress_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressControllerProvider);
    final levelRepo = ref.watch(levelRepositoryProvider);
    final currentLevel = progress.unlockedLevelId.clamp(
      levelRepo.firstId,
      levelRepo.lastId,
    );

    return Scaffold(
      body: NotebookBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DoodleMetrics.lg,
                    ),
                    child: Column(
                      children: [
                        _topBar(context, progress.coins),
                        const SizedBox(height: DoodleMetrics.sm),
                        _titleBlock(),
                        const _HomeHero(),
                        _progressSummary(
                          context,
                          progress.completedCount,
                          levelRepo.count,
                          progress.totalStars,
                        ),
                        const SizedBox(height: DoodleMetrics.lg),
                        _buttons(context, currentLevel),
                        const SizedBox(height: DoodleMetrics.lg),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, int coins) {
    return Row(
      children: [
        DoodleIconButton(
          icon: DoodleIconType.gear,
          semanticLabel: 'Settings',
          onPressed: () => context.go(AppRoutes.settings),
        ),
        const Spacer(),
        CoinCounter(coins: coins),
      ],
    );
  }

  Widget _titleBlock() {
    return Column(
      children: [
        Text(
          'Doodle Word Quest',
          textAlign: TextAlign.center,
          style: DoodleTextStyles.logo(),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2),
          height: 4,
          width: 180,
          decoration: BoxDecoration(
            color: DoodleColors.yellow,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    ).animate().fadeIn(duration: DoodleMetrics.medium).slideY(begin: -0.2);
  }

  Widget _progressSummary(
    BuildContext context,
    int completed,
    int total,
    int stars,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$completed / $total levels', style: DoodleTextStyles.bodySoft()),
        const SizedBox(width: DoodleMetrics.md),
        const DoodleIcon(DoodleIconType.star, size: 18),
        const SizedBox(width: 4),
        Text('$stars', style: DoodleTextStyles.bodySoft()),
      ],
    );
  }

  Widget _buttons(BuildContext context, int currentLevel) {
    final buttons = <Widget>[
      DoodleButton(
        label: 'Continue • Level $currentLevel',
        expand: true,
        icon: const DoodleIcon(DoodleIconType.arrowRight, size: 22),
        onPressed: () => context.go(AppRoutes.game(currentLevel)),
      ),
      DoodleButton(
        label: 'Level Select',
        variant: DoodleButtonVariant.secondary,
        expand: true,
        onPressed: () => context.go(AppRoutes.levels),
      ),
      DoodleButton(
        label: 'Two Player',
        variant: DoodleButtonVariant.secondary,
        expand: true,
        onPressed: () => context.go(AppRoutes.twoPlayerSetup),
      ),
      DoodleButton(
        label: 'Daily Challenge',
        variant: DoodleButtonVariant.secondary,
        expand: true,
        onPressed: () => context.go(AppRoutes.daily),
      ),
    ];
    return Column(
      children: [
        for (var i = 0; i < buttons.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: DoodleMetrics.md),
            child: buttons[i]
                .animate()
                .fadeIn(delay: (80 * i).ms, duration: DoodleMetrics.medium)
                .slideY(begin: 0.25, curve: Curves.easeOut),
          ),
      ],
    );
  }
}

/// Cheerful floating mascot reused from the gameplay scene painter.
class _HomeHero extends StatelessWidget {
  const _HomeHero();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: DoodleMetrics.sm),
      child: SizedBox(
        height: 200,
        child: CharacterScene(
          theme: SceneTheme.balloonDrift,
          wrongCount: 0,
          maxMistakes: 6,
          phase: GamePhase.won,
        ),
      ),
    );
  }
}
