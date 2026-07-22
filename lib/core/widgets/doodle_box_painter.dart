import 'package:flutter/material.dart';

import '../../app/theme/doodle_colors.dart';
import '../../app/theme/doodle_metrics.dart';
import 'hand_drawn.dart';

/// Paints a hand-drawn rounded rectangle (optionally with an offset shadow
/// slab). Shared by [DoodleButton], [DoodleCard] and friends.
class DoodleBoxPainter extends CustomPainter {
  const DoodleBoxPainter({
    required this.fillColor,
    this.borderColor = DoodleColors.ink,
    this.strokeWidth = DoodleMetrics.strokeHeavy,
    this.radius = DoodleMetrics.radiusMd,
    this.shadowOffset = Offset.zero,
    this.seed = 11,
  });

  final Color fillColor;
  final Color borderColor;
  final double strokeWidth;
  final double radius;
  final Offset shadowOffset;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth / 2 + 0.5;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2 - shadowOffset.dx.abs(),
      size.height - inset * 2 - shadowOffset.dy.abs(),
    );

    if (shadowOffset != Offset.zero) {
      final shadowPath = HandDrawn.roughRRect(
        rect.shift(shadowOffset),
        radius,
        seed: seed + 1,
      );
      canvas.drawPath(shadowPath, HandDrawn.fill(DoodleColors.shadow));
    }

    final path = HandDrawn.roughRRect(rect, radius, seed: seed);
    canvas.drawPath(path, HandDrawn.fill(fillColor));
    canvas.drawPath(
      path,
      HandDrawn.inkStroke(width: strokeWidth, color: borderColor),
    );
  }

  @override
  bool shouldRepaint(DoodleBoxPainter old) =>
      old.fillColor != fillColor ||
      old.borderColor != borderColor ||
      old.strokeWidth != strokeWidth ||
      old.radius != radius ||
      old.shadowOffset != shadowOffset ||
      old.seed != seed;
}
