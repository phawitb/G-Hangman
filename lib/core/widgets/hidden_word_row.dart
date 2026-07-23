import 'package:flutter/material.dart';

import '../../app/theme/doodle_colors.dart';
import '../../app/theme/doodle_metrics.dart';
import '../../app/theme/doodle_text_styles.dart';
import '../utilities/word_utils.dart';

/// Renders the masked answer as a row of underlined slots. Revealed letters pop
/// in; separators (spaces / punctuation) show as gaps or the raw character.
class HiddenWordRow extends StatelessWidget {
  const HiddenWordRow({
    super.key,
    required this.characters,
    this.slotWidth = 30,
    this.slotHeight = 48,
  });

  /// Each entry: a revealed character, a separator character, or null (blank).
  final List<String?> characters;
  final double slotWidth;
  final double slotHeight;

  @override
  Widget build(BuildContext context) {
    final revealed = characters.where((c) => c != null).map((c) => c!).join();
    return Semantics(
      label: 'Answer so far: ${revealed.isEmpty ? 'blank' : revealed}',
      // Always keep the answer slots on a single line: lay them out in one Row
      // and scale the whole row down to fit the width when the word is long.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < characters.length; i++) ...[
              if (i > 0) const SizedBox(width: DoodleMetrics.sm),
              _slot(characters[i], i),
            ],
          ],
        ),
      ),
    );
  }

  Widget _slot(String? ch, int index) {
    final isSeparator = ch != null && ch.trim().isEmpty;
    if (isSeparator) {
      // Word break: a visible gap.
      return SizedBox(width: slotWidth * 0.6, height: slotHeight);
    }
    final isPunctuation = ch != null && !WordUtils.isLetter(ch);

    return SizedBox(
      width: slotWidth,
      height: slotHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: DoodleMetrics.medium,
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: CurvedAnimation(
                    parent: anim,
                    curve: Curves.easeOutBack,
                  ),
                  child: child,
                ),
                child: Text(
                  ch ?? '',
                  key: ValueKey('$index-${ch ?? '_'}'),
                  style: DoodleTextStyles.keycap().copyWith(
                    fontSize: slotHeight * 0.6,
                    color: DoodleColors.ink,
                  ),
                ),
              ),
            ),
          ),
          if (!isPunctuation)
            Container(
              height: 4,
              width: slotWidth,
              margin: const EdgeInsets.only(top: 3),
              decoration: BoxDecoration(
                color: DoodleColors.ink,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
        ],
      ),
    );
  }
}
