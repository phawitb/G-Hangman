import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/doodle_colors.dart';
import '../../../app/theme/doodle_metrics.dart';
import '../../../app/theme/doodle_text_styles.dart';
import '../../../core/widgets/doodle_button.dart';
import '../../../core/widgets/doodle_card.dart';
import '../../../core/widgets/bottom_reserve.dart';
import '../../../core/widgets/doodle_confetti.dart';
import '../../../core/widgets/doodle_icons.dart';
import '../../../core/widgets/notebook_background.dart';
import '../../../core/widgets/reward_progress_track.dart';
import '../../../core/constants/economy.dart';
import '../../ads/application/ad_providers.dart';
import '../../gameplay/application/game_mode.dart';
import '../../localization/application/locale_controller.dart';
import '../../localization/domain/str_key.dart';
import '../../progression/application/progress_controller.dart';
import '../domain/result_args.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key, required this.args});

  final ResultArgs args;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  int? _chestReward;
  bool _chestOpening = false;

  ResultArgs get args => widget.args;

  Future<void> _openChest() async {
    if (_chestOpening) return;
    setState(() => _chestOpening = true);
    final reward = await ref
        .read(progressControllerProvider.notifier)
        .openChest();
    if (!mounted) return;
    setState(() {
      _chestReward = reward;
      _chestOpening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final won = args.won;
    return Scaffold(
      body: NotebookBackground(
        child: SafeArea(
          child: BottomReserve(
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(DoodleMetrics.xl),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: won ? _buildWin(context) : _buildLoss(context),
                    ),
                  ),
                ),
                if (won) const Positioned.fill(child: DoodleConfetti()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---- Win -----------------------------------------------------------------

  Widget _buildWin(BuildContext context) {
    final state = args.finalState;
    final progress = ref.watch(progressControllerProvider);
    final isAdventure = args.mode == GameMode.adventure;
    final t = ref.read(translateProvider);

    return DoodleCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t(StrKey.greatJob), style: DoodleTextStyles.heading()),
          const SizedBox(height: DoodleMetrics.sm),
          _StarRow(stars: state.stars),
          const SizedBox(height: DoodleMetrics.md),
          _AnswerReveal(answer: state.level.normalizedAnswer),
          if (state.level.explanation != null) ...[
            const SizedBox(height: DoodleMetrics.sm),
            Text(
              state.level.explanation!,
              textAlign: TextAlign.center,
              style: DoodleTextStyles.bodySoft(),
            ),
          ],
          const SizedBox(height: DoodleMetrics.lg),
          _StatsGrid(
            coinsEarned: args.coinsEarned,
            accuracy: state.accuracy,
            wrongGuesses: state.wrongCount,
            coinsLabel: t(StrKey.statCoins),
            accuracyLabel: t(StrKey.statAccuracy),
            mistakesLabel: t(StrKey.statMistakes),
            streakLabel: args.mode == GameMode.daily
                ? t(StrKey.statDailyStreak)
                : t(StrKey.statStreak),
            streak: args.mode == GameMode.daily
                ? (args.dailyStreak ?? 0)
                : progress.currentStreak,
          ),
          if (isAdventure) ...[
            const SizedBox(height: DoodleMetrics.lg),
            Text(t(StrKey.rewardChest), style: DoodleTextStyles.label()),
            const SizedBox(height: DoodleMetrics.sm),
            RewardProgressTrack(
              filled: progress.winsTowardChest,
              total: Economy.winsPerChest,
            ),
            if (_chestReward != null) ...[
              const SizedBox(height: DoodleMetrics.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const DoodleIcon(DoodleIconType.coin, size: 20),
                  const SizedBox(width: DoodleMetrics.xs),
                  Text(
                    t(StrKey.chestReward, {'n': _chestReward!}),
                    style: DoodleTextStyles.body(),
                  ),
                ],
              ),
            ] else if (progress.chestReady) ...[
              const SizedBox(height: DoodleMetrics.md),
              DoodleButton(
                label: t(StrKey.openChest),
                variant: DoodleButtonVariant.success,
                icon: const DoodleIcon(DoodleIconType.chest, size: 22),
                onPressed: _chestOpening ? null : _openChest,
              ),
            ],
          ],
          const SizedBox(height: DoodleMetrics.xl),
          _winActions(context),
        ],
      ),
    );
  }

  /// Navigates after optionally showing an interstitial (adventure wins only,
  /// every Nth completed level). Falls through to navigation if no ad is shown.
  Future<void> _leaveAfterWin(String route) async {
    await ref.read(adServiceProvider).maybeShowInterstitial();
    if (mounted) context.go(route);
  }

  Widget _winActions(BuildContext context) {
    final t = ref.read(translateProvider);
    switch (args.mode) {
      case GameMode.adventure:
        return Row(
          children: [
            Expanded(
              child: DoodleButton(
                label: t(StrKey.replay),
                variant: DoodleButtonVariant.secondary,
                expand: true,
                onPressed: () => _leaveAfterWin(AppRoutes.game(args.level.id)),
              ),
            ),
            const SizedBox(width: DoodleMetrics.md),
            Expanded(
              child: DoodleButton(
                label: args.nextLevelId != null
                    ? t(StrKey.next)
                    : t(StrKey.home),
                expand: true,
                icon: const DoodleIcon(DoodleIconType.arrowRight, size: 22),
                onPressed: () => _leaveAfterWin(
                  args.nextLevelId != null
                      ? AppRoutes.game(args.nextLevelId!)
                      : AppRoutes.home,
                ),
              ),
            ),
          ],
        );
      case GameMode.daily:
        return DoodleButton(
          label: t(StrKey.backToHome),
          expand: true,
          onPressed: () => context.go(AppRoutes.home),
        );
      case GameMode.twoPlayer:
        return Row(
          children: [
            Expanded(
              child: DoodleButton(
                label: t(StrKey.home),
                variant: DoodleButtonVariant.secondary,
                expand: true,
                onPressed: () => context.go(AppRoutes.home),
              ),
            ),
            const SizedBox(width: DoodleMetrics.md),
            Expanded(
              child: DoodleButton(
                label: t(StrKey.newRound),
                expand: true,
                onPressed: () => context.go(AppRoutes.twoPlayerSetup),
              ),
            ),
          ],
        );
    }
  }

  // ---- Loss ----------------------------------------------------------------

  Widget _buildLoss(BuildContext context) {
    final state = args.finalState;
    final t = ref.read(translateProvider);
    return DoodleCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t(StrKey.outOfChances), style: DoodleTextStyles.heading()),
          const SizedBox(height: DoodleMetrics.sm),
          Text(
            t(StrKey.lossEncourage),
            textAlign: TextAlign.center,
            style: DoodleTextStyles.body(),
          ),
          const SizedBox(height: DoodleMetrics.lg),
          Text(t(StrKey.theAnswerWas), style: DoodleTextStyles.label()),
          const SizedBox(height: DoodleMetrics.xs),
          _AnswerReveal(answer: state.level.normalizedAnswer),
          if (state.level.explanation != null) ...[
            const SizedBox(height: DoodleMetrics.md),
            Text(
              state.level.explanation!,
              textAlign: TextAlign.center,
              style: DoodleTextStyles.bodySoft(),
            ),
          ],
          const SizedBox(height: DoodleMetrics.xl),
          _lossActions(context),
        ],
      ),
    );
  }

  Widget _lossActions(BuildContext context) {
    final t = ref.read(translateProvider);
    final retryTarget = switch (args.mode) {
      GameMode.adventure => AppRoutes.game(args.level.id),
      GameMode.daily => AppRoutes.daily,
      GameMode.twoPlayer => AppRoutes.twoPlayerSetup,
    };
    final secondaryLabel = args.mode == GameMode.adventure
        ? t(StrKey.levelSelect)
        : t(StrKey.home);
    final secondaryTarget = args.mode == GameMode.adventure
        ? AppRoutes.levels
        : AppRoutes.home;
    return Row(
      children: [
        Expanded(
          child: DoodleButton(
            label: secondaryLabel,
            variant: DoodleButtonVariant.secondary,
            expand: true,
            onPressed: () => context.go(secondaryTarget),
          ),
        ),
        const SizedBox(width: DoodleMetrics.md),
        Expanded(
          child: DoodleButton(
            label: t(StrKey.tryAgain),
            expand: true,
            onPressed: () => context.go(retryTarget),
          ),
        ),
      ],
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.stars});
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$stars out of 3 stars',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final earned = i < stars;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: DoodleIcon(
              earned ? DoodleIconType.star : DoodleIconType.starOutline,
              size: 40,
              fill: earned ? DoodleColors.yellow : DoodleColors.disabledFill,
              ink: earned ? DoodleColors.ink : DoodleColors.disabledInk,
            ),
          );
        }),
      ),
    );
  }
}

class _AnswerReveal extends StatelessWidget {
  const _AnswerReveal({required this.answer});
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Text(
      answer,
      textAlign: TextAlign.center,
      style: DoodleTextStyles.heading().copyWith(letterSpacing: 2),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.coinsEarned,
    required this.accuracy,
    required this.wrongGuesses,
    required this.streak,
    required this.coinsLabel,
    required this.accuracyLabel,
    required this.mistakesLabel,
    required this.streakLabel,
  });

  final int coinsEarned;
  final double accuracy;
  final int wrongGuesses;
  final int streak;
  final String coinsLabel;
  final String accuracyLabel;
  final String mistakesLabel;
  final String streakLabel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DoodleMetrics.md,
      runSpacing: DoodleMetrics.md,
      alignment: WrapAlignment.center,
      children: [
        _stat(coinsLabel, '+$coinsEarned', DoodleIconType.coin),
        _stat(accuracyLabel, '${(accuracy * 100).round()}%', null),
        _stat(mistakesLabel, '$wrongGuesses', null),
        _stat(streakLabel, '$streak', DoodleIconType.sparkle),
      ],
    );
  }

  Widget _stat(String label, String value, DoodleIconType? icon) {
    return SizedBox(
      width: 120,
      child: DoodleCard(
        padding: const EdgeInsets.symmetric(
          horizontal: DoodleMetrics.sm,
          vertical: DoodleMetrics.sm,
        ),
        shadow: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  DoodleIcon(icon, size: 18),
                  const SizedBox(width: 4),
                ],
                Text(value, style: DoodleTextStyles.title()),
              ],
            ),
            Text(label, style: DoodleTextStyles.label()),
          ],
        ),
      ),
    );
  }
}
