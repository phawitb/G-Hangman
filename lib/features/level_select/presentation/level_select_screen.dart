import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/doodle_colors.dart';
import '../../../app/theme/doodle_metrics.dart';
import '../../../app/theme/doodle_text_styles.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/doodle_icon_button.dart';
import '../../../core/widgets/doodle_icons.dart';
import '../../../core/widgets/notebook_background.dart';
import '../../gameplay/domain/game_level.dart';
import '../../progression/application/progress_controller.dart';
import '../../progression/domain/player_progress.dart';

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressControllerProvider);
    final levels = ref.watch(levelRepositoryProvider).all;

    return Scaffold(
      body: NotebookBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(DoodleMetrics.lg),
                child: Row(
                  children: [
                    DoodleIconButton(
                      icon: DoodleIconType.back,
                      semanticLabel: 'Back to Home',
                      size: 44,
                      onPressed: () => context.go(AppRoutes.home),
                    ),
                    const SizedBox(width: DoodleMetrics.sm),
                    Text('Level Select', style: DoodleTextStyles.heading()),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    DoodleMetrics.lg,
                    0,
                    DoodleMetrics.lg,
                    DoodleMetrics.xxl,
                  ),
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final level = levels[index];
                    // Alternate sides for a winding "path" feel.
                    final alignment = index.isEven
                        ? Alignment.centerLeft
                        : Alignment.centerRight;
                    return Align(
                      alignment: alignment,
                      child: _LevelNode(level: level, progress: progress),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelNode extends StatelessWidget {
  const _LevelNode({required this.level, required this.progress});

  final GameLevel level;
  final PlayerProgress progress;

  @override
  Widget build(BuildContext context) {
    final unlocked = progress.isUnlocked(level.id);
    final stars = progress.starsFor(level.id);
    final isCurrent = level.id == progress.unlockedLevelId && stars == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DoodleMetrics.sm),
      child: Semantics(
        button: unlocked,
        label: unlocked
            ? 'Level ${level.id}, ${level.category}, $stars stars'
            : 'Level ${level.id}, locked',
        child: GestureDetector(
          onTap: unlocked ? () => context.go(AppRoutes.game(level.id)) : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _circle(unlocked, isCurrent),
              const SizedBox(width: DoodleMetrics.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.category,
                    style: DoodleTextStyles.body().copyWith(
                      color: unlocked
                          ? DoodleColors.ink
                          : DoodleColors.disabledInk,
                    ),
                  ),
                  if (unlocked && stars > 0) _stars(stars),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle(bool unlocked, bool isCurrent) {
    final fill = !unlocked
        ? DoodleColors.disabledFill
        : isCurrent
        ? DoodleColors.yellow
        : DoodleColors.paper;
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(
          color: unlocked ? DoodleColors.ink : DoodleColors.disabledInk,
          width: isCurrent ? 3.2 : 2.4,
        ),
      ),
      child: unlocked
          ? Text(
              '${level.id}',
              style: DoodleTextStyles.keycap().copyWith(fontSize: 24),
            )
          : const DoodleIcon(DoodleIconType.lock, size: 26),
    );
  }

  Widget _stars(int stars) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final earned = i < stars;
        return DoodleIcon(
          earned ? DoodleIconType.star : DoodleIconType.starOutline,
          size: 16,
          fill: earned ? DoodleColors.yellow : DoodleColors.disabledFill,
          ink: earned ? DoodleColors.ink : DoodleColors.disabledInk,
        );
      }),
    );
  }
}
