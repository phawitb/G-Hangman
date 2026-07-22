import 'package:flutter/material.dart';

import '../../app/theme/doodle_colors.dart';
import '../../app/theme/doodle_metrics.dart';
import '../../app/theme/doodle_text_styles.dart';
import 'doodle_box_painter.dart';
import 'doodle_icons.dart';

/// Coin balance pill. The number tweens when the balance changes so earning
/// coins feels rewarding.
class CoinCounter extends StatelessWidget {
  const CoinCounter({super.key, required this.coins, this.iconSize = 22});

  final int coins;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$coins coins',
      child: CustomPaint(
        painter: DoodleBoxPainter(
          fillColor: DoodleColors.paper,
          radius: DoodleMetrics.radiusXl,
          strokeWidth: DoodleMetrics.strokeMedium,
          shadowOffset: const Offset(1.5, 2),
          seed: 33,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DoodleMetrics.md,
            vertical: DoodleMetrics.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DoodleIcon(DoodleIconType.coin, size: iconSize),
              const SizedBox(width: DoodleMetrics.sm),
              TweenAnimationBuilder<double>(
                tween: Tween(end: coins.toDouble()),
                duration: DoodleMetrics.slow,
                curve: Curves.easeOut,
                builder: (context, value, _) => Text(
                  value.round().toString(),
                  style: DoodleTextStyles.counter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
