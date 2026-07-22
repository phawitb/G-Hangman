import 'package:flutter/material.dart';

import '../../app/theme/doodle_colors.dart';
import '../../app/theme/doodle_metrics.dart';
import '../../app/theme/doodle_text_styles.dart';
import 'doodle_box_painter.dart';

/// A small pill used for category chips and level labels.
class LevelBadge extends StatelessWidget {
  const LevelBadge({
    super.key,
    required this.text,
    this.fill = DoodleColors.yellow,
    this.icon,
  });

  final String text;
  final Color fill;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DoodleBoxPainter(
        fillColor: fill,
        radius: DoodleMetrics.radiusXl,
        strokeWidth: DoodleMetrics.strokeMedium,
        shadowOffset: const Offset(1, 1.5),
        seed: text.hashCode & 0x3f,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DoodleMetrics.md,
          vertical: DoodleMetrics.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: DoodleMetrics.xs),
            ],
            Text(
              text,
              style: DoodleTextStyles.label().copyWith(color: DoodleColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}
