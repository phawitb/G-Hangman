import 'package:flutter/material.dart';

import '../../app/theme/doodle_colors.dart';
import '../../app/theme/doodle_metrics.dart';
import 'doodle_box_painter.dart';

/// A hand-drawn card: rough rounded rectangle, paper fill, subtle rotation for
/// personality. Content is padded for readability.
class DoodleCard extends StatelessWidget {
  const DoodleCard({
    super.key,
    required this.child,
    this.fill = DoodleColors.paper,
    this.padding = const EdgeInsets.all(DoodleMetrics.lg),
    this.rotation = 0,
    this.shadow = true,
    this.radius = DoodleMetrics.radiusLg,
    this.seed = 21,
  });

  final Widget child;
  final Color fill;
  final EdgeInsets padding;
  final double rotation;
  final bool shadow;
  final double radius;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final card = CustomPaint(
      painter: DoodleBoxPainter(
        fillColor: fill,
        radius: radius,
        strokeWidth: DoodleMetrics.strokeMedium,
        shadowOffset: shadow ? const Offset(2, 3) : Offset.zero,
        seed: seed,
      ),
      child: Padding(padding: padding, child: child),
    );
    if (rotation == 0) return card;
    return Transform.rotate(angle: rotation, child: card);
  }
}
