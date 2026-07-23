import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/doodle_colors.dart';
import '../../../app/theme/doodle_metrics.dart';
import '../../../app/theme/doodle_text_styles.dart';
import '../../../core/constants/game_config.dart';
import '../../../core/widgets/doodle_button.dart';
import '../../../core/widgets/doodle_card.dart';
import '../../../core/widgets/doodle_icon_button.dart';
import '../../../core/widgets/doodle_icons.dart';
import '../../../core/widgets/doodle_keyboard.dart';
import '../../../core/widgets/notebook_background.dart';
import '../../localization/application/locale_controller.dart';
import '../../localization/domain/str_key.dart';
import '../domain/two_player_word.dart';

enum _Field { word, clue }

/// Player 1 sets a secret word, optional clue and difficulty for Player 2.
/// All text entry uses the in-app [DoodleKeyboard] — never the system keyboard.
class TwoPlayerSetupScreen extends ConsumerStatefulWidget {
  const TwoPlayerSetupScreen({super.key});

  @override
  ConsumerState<TwoPlayerSetupScreen> createState() =>
      _TwoPlayerSetupScreenState();
}

class _TwoPlayerSetupScreenState extends ConsumerState<TwoPlayerSetupScreen> {
  static const int _wordMax = 30;
  static const int _clueMax = 80;

  String _word = '';
  String _clue = '';
  bool _obscure = true;
  int _maxMistakes = GameConfig.twoPlayerDefaultMistakes;
  TwoPlayerError? _error;
  _Field? _active;

  void _focus(_Field field) => setState(() => _active = field);

  void _onCharacter(String ch) {
    setState(() {
      _error = null;
      if (_active == _Field.word) {
        if (_word.length < _wordMax) _word += ch;
      } else if (_active == _Field.clue) {
        if (_clue.length < _clueMax) _clue += ch;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_active == _Field.word && _word.isNotEmpty) {
        _word = _word.substring(0, _word.length - 1);
      } else if (_active == _Field.clue && _clue.isNotEmpty) {
        _clue = _clue.substring(0, _clue.length - 1);
      }
    });
  }

  void _start() {
    setState(() => _active = null);
    final error = TwoPlayerWord.validate(_word);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    final t = ref.read(translateProvider);
    final level = TwoPlayerWord.buildLevel(
      secret: _word,
      clue: _clue,
      maxMistakes: _maxMistakes,
      category: t(StrKey.twoPlayerCategory),
      defaultClue: t(StrKey.twoPlayerClue),
      alphabet: ref.read(localeControllerProvider).language.alphabet,
    );
    context.go(AppRoutes.twoPlayerGame, extra: level);
  }

  String _errorText(TwoPlayerError error, Translate t) => switch (error) {
    TwoPlayerError.empty => t(StrKey.valEmpty),
    TwoPlayerError.chars => t(StrKey.valChars),
    TwoPlayerError.needsLetter => t(StrKey.valNeedsLetter),
    TwoPlayerError.tooShort => t(StrKey.valMinLen, {
      'n': GameConfig.twoPlayerMinWordLength,
    }),
    TwoPlayerError.tooLong => t(StrKey.valMaxLen, {
      'n': GameConfig.twoPlayerMaxWordLength,
    }),
  };

  @override
  Widget build(BuildContext context) {
    // Small fixed gap; the shared banner footer now sits below every screen.
    const bottomGap = DoodleMetrics.md;
    final t = ref.watch(translateProvider);
    final alphabet = ref.watch(localeControllerProvider).language.alphabet;
    return Scaffold(
      body: NotebookBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: _form(t)),
              // In-app keyboard when a field is active; otherwise a 15% gap.
              if (_active != null)
                DoodleKeyboard(
                  alphabet: alphabet,
                  onCharacter: _onCharacter,
                  onBackspace: _onBackspace,
                  onDone: () => setState(() => _active = null),
                )
              else
                SizedBox(height: bottomGap),
            ],
          ),
        ),
      ),
    );
  }

  Widget _form(Translate t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DoodleMetrics.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DoodleIconButton(
                icon: DoodleIconType.back,
                semanticLabel: t(StrKey.back),
                size: 44,
                onPressed: () => context.go(AppRoutes.home),
              ),
              const SizedBox(width: DoodleMetrics.sm),
              Text(t(StrKey.twoPlayerTitle), style: DoodleTextStyles.heading()),
            ],
          ),
          const SizedBox(height: DoodleMetrics.lg),
          DoodleCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t(StrKey.playerOne), style: DoodleTextStyles.title()),
                Text(
                  t(StrKey.secretPrompt),
                  style: DoodleTextStyles.bodySoft(),
                ),
                const SizedBox(height: DoodleMetrics.md),
                _label(t(StrKey.secretWordLabel)),
                _InputBox(
                  value: _obscure ? '•' * _word.length : _word,
                  hint: t(StrKey.secretHint),
                  active: _active == _Field.word,
                  onTap: () => _focus(_Field.word),
                  trailing: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    color: DoodleColors.inkSoft,
                    tooltip: _obscure ? t(StrKey.showWord) : t(StrKey.hideWord),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: DoodleMetrics.xs),
                  Text(
                    _errorText(_error!, t),
                    style: DoodleTextStyles.label().copyWith(
                      color: DoodleColors.red,
                    ),
                  ),
                ],
                const SizedBox(height: DoodleMetrics.md),
                _label(t(StrKey.clueOptionalLabel)),
                _InputBox(
                  value: _clue,
                  hint: t(StrKey.clueHint),
                  active: _active == _Field.clue,
                  onTap: () => _focus(_Field.clue),
                ),
              ],
            ),
          ),
          const SizedBox(height: DoodleMetrics.lg),
          DoodleCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t(StrKey.allowedMistakes, {'n': _maxMistakes}),
                  style: DoodleTextStyles.title(),
                ),
                Slider(
                  value: _maxMistakes.toDouble(),
                  min: GameConfig.twoPlayerMinMistakes.toDouble(),
                  max: GameConfig.twoPlayerMaxMistakes.toDouble(),
                  divisions:
                      GameConfig.twoPlayerMaxMistakes -
                      GameConfig.twoPlayerMinMistakes,
                  label: '$_maxMistakes',
                  activeColor: DoodleColors.blue,
                  onChanged: (v) => setState(() {
                    _active = null;
                    _maxMistakes = v.round();
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: DoodleMetrics.xl),
          DoodleButton(
            label: t(StrKey.passToPlayer2),
            expand: true,
            icon: const DoodleIcon(DoodleIconType.arrowRight, size: 22),
            onPressed: _start,
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: DoodleMetrics.xs),
    child: Text(text, style: DoodleTextStyles.label()),
  );
}

/// A tappable text box that displays the current value and opens the in-app
/// keyboard. Highlights when active.
class _InputBox extends StatelessWidget {
  const _InputBox({
    required this.value,
    required this.hint,
    required this.active,
    required this.onTap,
    this.trailing,
  });

  final String value;
  final String hint;
  final bool active;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final empty = value.isEmpty;
    return Semantics(
      button: true,
      label: '$hint. ${empty ? 'empty' : value}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: DoodleMetrics.minTap),
          padding: const EdgeInsets.symmetric(
            horizontal: DoodleMetrics.md,
            vertical: DoodleMetrics.sm,
          ),
          decoration: BoxDecoration(
            color: DoodleColors.paperDeep,
            borderRadius: BorderRadius.circular(DoodleMetrics.radiusMd),
            border: Border.all(
              color: active ? DoodleColors.blue : DoodleColors.ink,
              width: active ? 2.6 : 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  empty ? hint : value,
                  style: DoodleTextStyles.body().copyWith(
                    color: empty ? DoodleColors.inkFaint : DoodleColors.ink,
                    letterSpacing: 1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (active)
                Container(width: 2, height: 22, color: DoodleColors.blue),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
