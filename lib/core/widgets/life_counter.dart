import 'package:flutter/material.dart';

import '../../app/theme/doodle_colors.dart';
import '../../app/theme/doodle_metrics.dart';
import 'doodle_icons.dart';

/// Shows remaining chances as filled hearts and lost ones as faint outlines.
class LifeCounter extends StatelessWidget {
  const LifeCounter({
    super.key,
    required this.remaining,
    required this.total,
    this.heartSize = 22,
    this.maxHearts = 8,
  });

  final int remaining;
  final int total;
  final double heartSize;
  final int maxHearts;

  @override
  Widget build(BuildContext context) {
    // Keep the row compact on small screens by capping the drawn hearts.
    final shown = total.clamp(0, maxHearts);
    final scale = total <= maxHearts ? 1.0 : maxHearts / total;
    final remainingShown = (remaining * scale).round().clamp(0, shown);

    return Semantics(
      label: '$remaining of $total chances left',
      child: Wrap(
        spacing: DoodleMetrics.xs,
        children: List.generate(shown, (i) {
          final alive = i < remainingShown;
          return DoodleIcon(
            alive ? DoodleIconType.heart : DoodleIconType.heart,
            size: heartSize,
            fill: alive ? DoodleColors.red : DoodleColors.disabledFill,
            ink: alive ? DoodleColors.ink : DoodleColors.disabledInk,
          );
        }),
      ),
    );
  }
}
