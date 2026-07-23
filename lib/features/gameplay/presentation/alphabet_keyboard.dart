import 'package:flutter/material.dart';

import '../../../app/theme/doodle_metrics.dart';
import '../../../core/widgets/letter_tile.dart';
import '../domain/game_state.dart';

/// On-screen letter grid in plain A–Z (alphabetical) order, matching the
/// two-player secret-word keyboard. Keys size themselves to the available width
/// so it works from small phones up to tablets. Every letter keeps its slot so
/// the grid never reflows; letters cleared by the bomb hint fade away in place.
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
    const columns = 8;
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = DoodleMetrics.xs;
        final tileSize =
            ((constraints.maxWidth - spacing * (columns - 1)) / columns)
                .clamp(24.0, 44.0);
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: spacing,
          runSpacing: spacing,
          children: [
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
