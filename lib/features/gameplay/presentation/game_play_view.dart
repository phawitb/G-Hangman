import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/doodle_metrics.dart';
import '../../../app/theme/doodle_text_styles.dart';
import '../../../core/constants/economy.dart';
import '../../../core/widgets/bomb_burst.dart';
import '../../../core/widgets/character_scene.dart';
import '../../../core/widgets/coin_counter.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/doodle_icon_button.dart';
import '../../../core/widgets/doodle_icons.dart';
import '../../../core/widgets/hidden_word_row.dart';
import '../../../core/widgets/hint_button.dart';
import '../../../core/widgets/level_badge.dart';
import '../../../core/widgets/life_counter.dart';
import '../../../core/widgets/speech_bubble.dart';
import '../../ads/application/ad_providers.dart';
import '../../localization/application/locale_controller.dart';
import '../../localization/domain/str_key.dart';
import '../../progression/application/progress_controller.dart';
import '../application/game_controller.dart';
import '../domain/game_state.dart';
import '../domain/hangman_engine.dart';
import '../domain/hint_type.dart';
import 'alphabet_keyboard.dart';
import 'encouragement.dart';

/// The reusable gameplay board, shared by Adventure, Daily and Two-Player.
class GamePlayView extends ConsumerWidget {
  const GamePlayView({super.key, required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    if (state == null) {
      return const SizedBox.shrink();
    }
    final controller = ref.read(gameControllerProvider.notifier);
    final coinsEnabled = controller.coinsEnabled;
    final coins = coinsEnabled
        ? ref.watch(progressControllerProvider.select((p) => p.coins))
        : 0;
    final playing = state.phase == GamePhase.playing;
    final t = ref.watch(translateProvider);
    // A little breathing room beneath the keyboard / hint row. Kept small so the
    // scene, clue and hearts above always have space to show in full.
    final bottomSpace = MediaQuery.sizeOf(context).height * 0.06;

    return SafeArea(
      child: Column(
        children: [
          _TopBar(
            title: title,
            category: state.level.category,
            backLabel: t(StrKey.back),
            coins: coins,
            showCoins: coinsEnabled,
            onBack: onBack,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DoodleMetrics.lg,
              ),
              child: Column(
                children: [
                  // The scene flexes: it shrinks to give room so the clue and
                  // hearts below are ALWAYS fully visible (never scrolled off).
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Scene fills the flexible box (beside the bubble).
                            Positioned.fill(
                              child: CharacterScene(
                                theme: state.level.scene,
                                wrongCount: state.wrongCount,
                                maxMistakes: state.maxMistakes,
                                phase: state.phase,
                                fill: true,
                              ),
                            ),
                            // Encouragement bubble tucked beside the mascot head.
                            Positioned(
                              top: 0,
                              right: 0,
                              width: constraints.maxWidth * 0.58,
                              child: SpeechBubble(
                                message: t(Encouragement.forState(state)),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: DoodleMetrics.xs),
                  // Clue wraps to as many lines as it needs — never truncated.
                  _ClueCard(clue: state.level.clue),
                  // Hearts sit right under the question with a tight gap.
                  const SizedBox(height: DoodleMetrics.xs),
                  LifeCounter(
                    remaining: state.remainingMistakes,
                    total: state.maxMistakes,
                  ),
                  const SizedBox(height: DoodleMetrics.sm),
                ],
              ),
            ),
          ),
          // Hidden word + keyboard + hints are pinned so they stay visible,
          // with roughly 15% of the screen left empty below them.
          Padding(
            padding: EdgeInsets.only(
              left: DoodleMetrics.lg,
              right: DoodleMetrics.lg,
              top: DoodleMetrics.xs,
              bottom: bottomSpace,
            ),
            child: Column(
              children: [
                HiddenWordRow(characters: state.maskedCharacters),
                const SizedBox(height: DoodleMetrics.md),
                AlphabetKeyboard(
                  state: state,
                  enabled: playing,
                  onLetter: (letter) =>
                      ref.read(gameControllerProvider.notifier).guess(letter),
                ),
                if (coinsEnabled) ...[
                  const SizedBox(height: DoodleMetrics.md),
                  _HintRow(state: state, enabled: playing, coins: coins),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.category,
    required this.backLabel,
    required this.coins,
    required this.showCoins,
    required this.onBack,
  });

  final String title;
  final String category;
  final String backLabel;
  final int coins;
  final bool showCoins;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DoodleMetrics.md,
        DoodleMetrics.sm,
        DoodleMetrics.md,
        0,
      ),
      child: Row(
        children: [
          DoodleIconButton(
            icon: DoodleIconType.back,
            semanticLabel: backLabel,
            size: 44,
            onPressed: onBack,
          ),
          const SizedBox(width: DoodleMetrics.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DoodleTextStyles.title(),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                LevelBadge(text: category),
              ],
            ),
          ),
          if (showCoins) ...[
            const SizedBox(width: DoodleMetrics.sm),
            CoinCounter(coins: coins),
          ],
        ],
      ),
    );
  }
}

class _ClueCard extends StatelessWidget {
  const _ClueCard({required this.clue});
  final String clue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: DoodleMetrics.xs),
      child: Text(
        clue,
        textAlign: TextAlign.center,
        style: DoodleTextStyles.question(),
      ),
    );
  }
}

class _HintRow extends ConsumerWidget {
  const _HintRow({
    required this.state,
    required this.enabled,
    required this.coins,
  });

  final GameState state;
  final bool enabled;
  final int coins;

  static StrKey _labelKey(HintType type) => switch (type) {
    HintType.revealLetter => StrKey.hintReveal,
    HintType.removeLetters => StrKey.hintClear,
    HintType.extraChance => StrKey.hintPlusLife,
  };

  void _toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _use(BuildContext context, WidgetRef ref, HintType hint) async {
    final t = ref.read(translateProvider);

    // Out of coins → the hint's "▶ Ad" button plays a rewarded ad straight
    // away (no extra confirm step) and applies the hint for free.
    if (coins < hint.cost) {
      final adService = ref.read(adServiceProvider);
      if (!adService.canRequestAds) {
        _toast(context, t(StrKey.notEnoughCoins));
        return;
      }
      var earned = false;
      await adService.showRewarded(
        onReward: () => earned = true,
        onUnavailable: () {
          if (context.mounted) _toast(context, t(StrKey.noAdAvailable));
        },
        // Apply after the ad closes so the bomb burst is actually visible
        // (showing it under a full-screen ad would be wasted).
        onClosed: () {
          if (!earned || !context.mounted) return;
          if (hint == HintType.removeLetters) BombBurst.show(context);
          ref.read(gameControllerProvider.notifier).applyHintFromAd(hint);
        },
      );
      return;
    }

    // Coins path.
    if (hint == HintType.extraChance) {
      final ok = await showDoodleConfirm(
        context,
        title: t(StrKey.buyExtraTitle),
        message: t(StrKey.buyExtraMessage, {'n': hint.cost}),
        confirmLabel: t(StrKey.buy),
        cancelLabel: t(StrKey.noThanks),
      );
      if (!ok || !context.mounted) return;
    }
    // Bomb goes off first, then the letters get blown off the keyboard.
    if (hint == HintType.removeLetters) {
      BombBurst.show(context);
      await Future.delayed(const Duration(milliseconds: 320));
      if (!context.mounted) return;
    }
    final outcome = await ref
        .read(gameControllerProvider.notifier)
        .useHint(hint);
    if (!context.mounted) return;
    final text = switch (outcome) {
      HintOutcome.applied => null,
      HintOutcome.notEnoughCoins => t(StrKey.notEnoughCoins),
      HintOutcome.nothingToDo => t(StrKey.noLettersHint),
      HintOutcome.alreadyUsedMax => t(StrKey.alreadyExtra),
    };
    if (text != null) _toast(context, text);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translateProvider);
    final canReveal = HangmanEngine.canReveal(state);
    final canRemove = HangmanEngine.canRemove(state);
    final canExtra = HangmanEngine.canExtraChance(state);
    final adReady = ref.watch(adReadyProvider);

    Widget hint(HintType type, DoodleIconType icon, bool available) {
      final affordable = coins >= type.cost;
      // When out of coins the hint stays usable via a rewarded ad instead.
      final active = enabled && available && (affordable || adReady);
      return Expanded(
        child: HintButton(
          icon: icon,
          label: t(_labelKey(type), {'n': Economy.removeLettersCount}),
          cost: type.cost,
          affordable: affordable,
          watchAd: !affordable && adReady,
          onPressed: active ? () => _use(context, ref, type) : null,
        ),
      );
    }

    return Row(
      children: [
        hint(HintType.revealLetter, DoodleIconType.reveal, canReveal),
        const SizedBox(width: DoodleMetrics.sm),
        hint(HintType.removeLetters, DoodleIconType.bomb, canRemove),
        const SizedBox(width: DoodleMetrics.sm),
        hint(HintType.extraChance, DoodleIconType.heart, canExtra),
      ],
    );
  }
}
