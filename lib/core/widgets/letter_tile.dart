import 'package:flutter/material.dart';

import '../../app/theme/doodle_colors.dart';
import '../../app/theme/doodle_metrics.dart';
import '../../app/theme/doodle_text_styles.dart';
import 'hand_drawn.dart';

enum LetterState { unused, correct, wrong, removed }

/// A single alphabet key. Correct = green, wrong = red with a struck-through
/// line, removed = faint & disabled, unused = ink on paper. Only unused keys
/// are tappable, which prevents duplicate guesses.
class LetterTile extends StatefulWidget {
  const LetterTile({
    super.key,
    required this.letter,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final LetterState state;
  final VoidCallback? onTap;

  bool get enabled => state == LetterState.unused && onTap != null;

  @override
  State<LetterTile> createState() => _LetterTileState();
}

class _LetterTileState extends State<LetterTile> {
  bool _pressed = false;

  Color get _fill => switch (widget.state) {
    LetterState.unused => DoodleColors.paper,
    LetterState.correct => DoodleColors.green,
    LetterState.wrong => DoodleColors.red,
    LetterState.removed => DoodleColors.disabledFill,
  };

  Color get _textColor => switch (widget.state) {
    LetterState.unused => DoodleColors.ink,
    LetterState.correct => DoodleColors.paper,
    LetterState.wrong => DoodleColors.paper,
    LetterState.removed => DoodleColors.disabledInk,
  };

  String get _stateWord => switch (widget.state) {
    LetterState.unused => 'unused',
    LetterState.correct => 'correct',
    LetterState.wrong => 'incorrect',
    LetterState.removed => 'removed',
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: 'Letter ${widget.letter}, $_stateWord',
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: widget.enabled
            ? (_) => setState(() => _pressed = true)
            : null,
        onTapUp: widget.enabled
            ? (_) => setState(() => _pressed = false)
            : null,
        onTapCancel: widget.enabled
            ? () => setState(() => _pressed = false)
            : null,
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedScale(
          duration: DoodleMetrics.fast,
          scale: _pressed ? 0.9 : 1,
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _KeyPainter(
                fill: _fill,
                struck: widget.state == LetterState.wrong,
              ),
              child: Center(
                child: Text(
                  widget.letter,
                  style: DoodleTextStyles.keycap().copyWith(color: _textColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyPainter extends CustomPainter {
  const _KeyPainter({required this.fill, required this.struck});
  final Color fill;
  final bool struck;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    final path = HandDrawn.roughRRect(rect, DoodleMetrics.radiusSm, seed: 42);
    canvas.drawPath(path, HandDrawn.fill(fill));
    canvas.drawPath(
      path,
      HandDrawn.inkStroke(width: DoodleMetrics.strokeMedium),
    );
    if (struck) {
      canvas.drawPath(
        HandDrawn.roughLine(
          Offset(rect.left + 3, rect.top + 3),
          Offset(rect.right - 3, rect.bottom - 3),
        ),
        HandDrawn.inkStroke(width: DoodleMetrics.strokeMedium),
      );
    }
  }

  @override
  bool shouldRepaint(_KeyPainter old) =>
      old.fill != fill || old.struck != struck;
}
