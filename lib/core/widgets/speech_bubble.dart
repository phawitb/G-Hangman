import 'package:flutter/material.dart';

import '../../app/theme/doodle_colors.dart';
import '../../app/theme/doodle_metrics.dart';
import '../../app/theme/doodle_text_styles.dart';
import 'hand_drawn.dart';

/// A hand-drawn speech bubble with a little tail, used for the mascot's
/// encouragement lines.
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({
    super.key,
    required this.message,
    this.fill = DoodleColors.paper,
  });

  final String message;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Mascot says: $message',
      child: CustomPaint(
        painter: _BubblePainter(fill: fill),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            DoodleMetrics.lg,
            DoodleMetrics.md,
            DoodleMetrics.lg,
            DoodleMetrics.lg,
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: DoodleTextStyles.body(),
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter({required this.fill});
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final bodyRect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 10);
    final path = HandDrawn.roughRRect(
      bodyRect,
      DoodleMetrics.radiusLg,
      seed: 15,
    );
    // tail
    final tail = Path()
      ..moveTo(size.width * 0.30, bodyRect.bottom - 2)
      ..lineTo(size.width * 0.24, size.height - 1)
      ..lineTo(size.width * 0.42, bodyRect.bottom - 2)
      ..close();
    canvas.drawPath(path, HandDrawn.fill(fill));
    canvas.drawPath(tail, HandDrawn.fill(fill));
    canvas.drawPath(
      path,
      HandDrawn.inkStroke(width: DoodleMetrics.strokeMedium),
    );
    canvas.drawPath(
      tail,
      HandDrawn.inkStroke(width: DoodleMetrics.strokeMedium),
    );
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.fill != fill;
}
