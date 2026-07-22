import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../core/widgets/notebook_background.dart';
import '../domain/two_player_word.dart';

/// Player 1 sets a secret word, optional clue and difficulty for Player 2.
class TwoPlayerSetupScreen extends StatefulWidget {
  const TwoPlayerSetupScreen({super.key});

  @override
  State<TwoPlayerSetupScreen> createState() => _TwoPlayerSetupScreenState();
}

class _TwoPlayerSetupScreenState extends State<TwoPlayerSetupScreen> {
  final _wordController = TextEditingController();
  final _clueController = TextEditingController();
  bool _obscure = true;
  int _maxMistakes = GameConfig.twoPlayerDefaultMistakes;
  String? _error;

  @override
  void dispose() {
    _wordController.dispose();
    _clueController.dispose();
    super.dispose();
  }

  void _start() {
    final error = TwoPlayerWord.validate(_wordController.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    final level = TwoPlayerWord.buildLevel(
      secret: _wordController.text,
      clue: _clueController.text,
      maxMistakes: _maxMistakes,
    );
    context.go(AppRoutes.twoPlayerGame, extra: level);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotebookBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DoodleMetrics.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DoodleIconButton(
                      icon: DoodleIconType.back,
                      semanticLabel: 'Back',
                      size: 44,
                      onPressed: () => context.go(AppRoutes.home),
                    ),
                    const SizedBox(width: DoodleMetrics.sm),
                    Text('Two Player', style: DoodleTextStyles.heading()),
                  ],
                ),
                const SizedBox(height: DoodleMetrics.lg),
                DoodleCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Player 1', style: DoodleTextStyles.title()),
                      Text(
                        'Type a secret word for Player 2 to guess.',
                        style: DoodleTextStyles.bodySoft(),
                      ),
                      const SizedBox(height: DoodleMetrics.md),
                      _label('Secret word'),
                      TextField(
                        controller: _wordController,
                        obscureText: _obscure,
                        autocorrect: false,
                        enableSuggestions: false,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r"[A-Za-z '\-]"),
                          ),
                          LengthLimitingTextInputFormatter(30),
                        ],
                        style: DoodleTextStyles.body(),
                        decoration: _inputDecoration(
                          hint: 'e.g. RAINBOW',
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            color: DoodleColors.inkSoft,
                            tooltip: _obscure ? 'Show word' : 'Hide word',
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        onChanged: (_) {
                          if (_error != null) setState(() => _error = null);
                        },
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: DoodleMetrics.xs),
                        Text(
                          _error!,
                          style: DoodleTextStyles.label().copyWith(
                            color: DoodleColors.red,
                          ),
                        ),
                      ],
                      const SizedBox(height: DoodleMetrics.md),
                      _label('Clue (optional)'),
                      TextField(
                        controller: _clueController,
                        style: DoodleTextStyles.body(),
                        maxLength: 80,
                        decoration: _inputDecoration(
                          hint: 'Give a friendly hint',
                        ),
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
                        'Allowed mistakes: $_maxMistakes',
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
                        onChanged: (v) =>
                            setState(() => _maxMistakes = v.round()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DoodleMetrics.xl),
                DoodleButton(
                  label: 'Pass to Player 2',
                  expand: true,
                  icon: const DoodleIcon(DoodleIconType.arrowRight, size: 22),
                  onPressed: _start,
                ),
                const SizedBox(height: DoodleMetrics.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: DoodleMetrics.xs),
    child: Text(text, style: DoodleTextStyles.label()),
  );

  InputDecoration _inputDecoration({required String hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffix,
      filled: true,
      fillColor: DoodleColors.paperDeep,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DoodleMetrics.radiusMd),
        borderSide: const BorderSide(color: DoodleColors.ink, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DoodleMetrics.radiusMd),
        borderSide: const BorderSide(color: DoodleColors.blue, width: 2.4),
      ),
    );
  }
}
