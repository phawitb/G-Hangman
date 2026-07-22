import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/doodle_metrics.dart';
import '../../../app/theme/doodle_text_styles.dart';
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
    // Reserve roughly the bottom 15% of the screen as empty breathing room
    // beneath the keyboard / hint row.
    final bottomSpace = MediaQuery.sizeOf(context).height * 0.15;

    return SafeArea(
      child: Column(
        children: [
          _TopBar(
            title: title,
            category: state.level.category,
            coins: coins,
            showCoins: coinsEnabled,
            onBack: onBack,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: DoodleMetrics.lg),
              child: Column(
                children: [
                  // Scene with the encouragement bubble tucked into the empty
                  // sky beside the mascot's head.
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CharacterScene(
                            theme: state.level.scene,
                            wrongCount: state.wrongCount,
                            maxMistakes: state.maxMistakes,
                            phase: state.phase,
                            // Shorter scene so the board stays compact.
                            aspectRatio: 2.1,
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            width: constraints.maxWidth * 0.58,
                            child: SpeechBubble(
                              message: Encouragement.forState(state),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: DoodleMetrics.sm),
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
    required this.coins,
    required this.showCoins,
    required this.onBack,
  });

  final String title;
  final String category;
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
            semanticLabel: 'Back',
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
      padding: const EdgeInsets.all(DoodleMetrics.md),
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

  Future<void> _use(BuildContext context, WidgetRef ref, HintType hint) async {
    if (hint == HintType.extraChance) {
      final ok = await showDoodleConfirm(
        context,
        title: 'Buy an extra chance?',
        message:
            'Spend ${hint.cost} coins to add one more allowed mistake for this level.',
        confirmLabel: 'Buy',
      );
      if (!ok || !context.mounted) return;
    }
    final outcome = await ref
        .read(gameControllerProvider.notifier)
        .useHint(hint);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final text = switch (outcome) {
      HintOutcome.applied => null,
      HintOutcome.notEnoughCoins => 'Not enough coins for that hint.',
      HintOutcome.nothingToDo => 'No letters left for that hint.',
      HintOutcome.alreadyUsedMax => 'You already used an extra chance here.',
    };
    if (text != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canReveal = HangmanEngine.canReveal(state);
    final canRemove = HangmanEngine.canRemove(state);
    final canExtra = HangmanEngine.canExtraChance(state);

    Widget hint(HintType type, DoodleIconType icon, bool available) {
      final affordable = coins >= type.cost;
      final active = enabled && available && affordable;
      return Expanded(
        child: HintButton(
          icon: icon,
          label: type.shortLabel,
          cost: type.cost,
          affordable: affordable,
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
