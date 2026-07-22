import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/doodle_colors.dart';
import '../../../app/theme/doodle_metrics.dart';
import '../../../app/theme/doodle_text_styles.dart';
import '../../../core/widgets/character_scene.dart';
import '../../../core/widgets/coin_counter.dart';
import '../../../core/widgets/doodle_button.dart';
import '../../../core/widgets/doodle_card.dart';
import '../../../core/widgets/doodle_icons.dart';
import '../../../core/widgets/bottom_reserve.dart';
import '../../../core/widgets/hint_button.dart';
import '../../../core/widgets/letter_tile.dart';
import '../../../core/widgets/notebook_background.dart';
import '../../../core/widgets/speech_bubble.dart';
import '../../gameplay/domain/game_state.dart';
import '../../gameplay/domain/hint_type.dart';
import '../../gameplay/domain/scene_theme.dart';
import '../../localization/application/locale_controller.dart';
import '../../localization/domain/str_key.dart';
import '../../settings/application/settings_controller.dart';

class TutorialScreen extends ConsumerStatefulWidget {
  const TutorialScreen({super.key});

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  final _controller = PageController();
  int _page = 0;

  List<_Step> get _steps {
    final t = ref.read(translateProvider);
    return [
      _Step(
        title: t(StrKey.tut1Title),
        body: t(StrKey.tut1Body),
        demo: SpeechBubble(message: t(StrKey.tutDemoClue)),
      ),
      _Step(
        title: t(StrKey.tut2Title),
        body: t(StrKey.tut2Body),
        demo: _letterDemo(),
      ),
      _Step(
        title: t(StrKey.tut3Title),
        body: t(StrKey.tut3Body),
        demo: const SizedBox(
          height: 150,
          child: CharacterScene(
            theme: SceneTheme.balloonDrift,
            wrongCount: 3,
            maxMistakes: 6,
            phase: GamePhase.playing,
          ),
        ),
      ),
      _Step(
        title: t(StrKey.tut4Title),
        body: t(StrKey.tut4Body),
        demo: _hintDemo(),
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(settingsControllerProvider.notifier).completeTutorial();
    if (mounted) context.go(AppRoutes.home);
  }

  void _next() {
    if (_page < _steps.length - 1) {
      _controller.nextPage(
        duration: DoodleMetrics.medium,
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translateProvider);
    final steps = _steps;
    final isLast = _page == steps.length - 1;
    return Scaffold(
      body: NotebookBackground(
        child: SafeArea(
          child: BottomReserve(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(DoodleMetrics.md),
                    child: TextButton(
                      onPressed: _finish,
                      child: Text(
                        t(StrKey.skip),
                        style: DoodleTextStyles.body().copyWith(
                          color: DoodleColors.inkSoft,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemCount: steps.length,
                    itemBuilder: (context, i) => _StepView(step: steps[i]),
                  ),
                ),
                _dots(),
                Padding(
                  padding: const EdgeInsets.all(DoodleMetrics.lg),
                  child: DoodleButton(
                    label: isLast ? t(StrKey.startPlaying) : t(StrKey.next),
                    expand: true,
                    icon: isLast
                        ? null
                        : const DoodleIcon(DoodleIconType.arrowRight, size: 22),
                    onPressed: _next,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_steps.length, (i) {
        final active = i == _page;
        return AnimatedContainer(
          duration: DoodleMetrics.fast,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: active ? DoodleColors.yellow : DoodleColors.disabledFill,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: DoodleColors.ink, width: 1.5),
          ),
        );
      }),
    );
  }

  static Widget _letterDemo() {
    return Wrap(
      spacing: DoodleMetrics.sm,
      children: [
        for (final entry in const [
          ('B', LetterState.correct),
          ('E', LetterState.correct),
          ('X', LetterState.wrong),
          ('A', LetterState.unused),
        ])
          SizedBox(
            width: 48,
            child: LetterTile(letter: entry.$1, state: entry.$2, onTap: () {}),
          ),
      ],
    );
  }

  static Widget _hintDemo() {
    return Column(
      children: [
        const CoinCounter(coins: 150),
        const SizedBox(height: DoodleMetrics.md),
        Row(
          children: [
            Expanded(
              child: HintButton(
                icon: DoodleIconType.reveal,
                label: HintType.revealLetter.shortLabel,
                cost: HintType.revealLetter.cost,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: DoodleMetrics.sm),
            Expanded(
              child: HintButton(
                icon: DoodleIconType.bomb,
                label: HintType.removeLetters.shortLabel,
                cost: HintType.removeLetters.cost,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Step {
  const _Step({required this.title, required this.body, required this.demo});
  final String title;
  final String body;
  final Widget demo;
}

class _StepView extends StatelessWidget {
  const _StepView({required this.step});
  final _Step step;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DoodleMetrics.lg),
      child: Column(
        children: [
          const SizedBox(height: DoodleMetrics.md),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: DoodleTextStyles.heading(),
          ),
          const SizedBox(height: DoodleMetrics.lg),
          DoodleCard(child: Center(child: step.demo)),
          const SizedBox(height: DoodleMetrics.lg),
          Text(
            step.body,
            textAlign: TextAlign.center,
            style: DoodleTextStyles.body(),
          ),
        ],
      ),
    );
  }
}
