import 'package:flutter/material.dart';

import '../../../app/theme/doodle_metrics.dart';
import '../../../core/widgets/letter_tile.dart';
import '../domain/game_state.dart';

/// Responsive alphabet grid. Keys size themselves to the available width, so it
/// works from ~320px up to tablets, and each key carries its own state.
class AlphabetKeyboard extends StatelessWidget {
  const AlphabetKeyboard({
    super.key,
    required this.state,
    required this.onLetter,
    required this.enabled,
  });

  final GameState state;
  final ValueChanged<String> onLetter;
  final bool enabled;

  LetterState _stateFor(String letter) {
    if (state.isCorrectGuess(letter)) return LetterState.correct;
    if (state.isWrongGuess(letter)) return LetterState.wrong;
    if (state.isRemoved(letter)) return LetterState.removed;
    return LetterState.unused;
  }

  @override
  Widget build(BuildContext context) {
    const columns = 7;
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = DoodleMetrics.sm;
        final totalSpacing = spacing * (columns - 1);
        final tileSize = ((constraints.maxWidth - totalSpacing) / columns)
            .clamp(30.0, 60.0);
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: spacing,
          runSpacing: spacing,
          children: [
            // Every letter keeps its slot so the grid never reflows. Letters
            // cleared by the bomb hint simply fade away in place, leaving an
            // empty gap where they were.
            for (final letter in state.level.letters)
              SizedBox(
                width: tileSize,
                child: AnimatedOpacity(
                  duration: DoodleMetrics.medium,
                  curve: Curves.easeOut,
                  opacity: state.isRemoved(letter) ? 0.0 : 1.0,
                  child: LetterTile(
                    letter: letter,
                    // Show the plain letter as it dissolves (not a grey box).
                    state: state.isRemoved(letter)
                        ? LetterState.unused
                        : _stateFor(letter),
                    onTap: (enabled && !state.isRemoved(letter))
                        ? () => onLetter(letter)
                        : null,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
