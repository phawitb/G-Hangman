import 'dart:math';

import 'package:flutter/rendering.dart';

import '../../app/theme/doodle_colors.dart';
import '../../app/theme/doodle_metrics.dart';

/// Helpers for drawing slightly-imperfect "hand-drawn" shapes with a
/// deterministic wobble (seeded so a shape doesn't jitter every repaint).
abstract final class HandDrawn {
  static Paint inkStroke({
    double width = DoodleMetrics.strokeMedium,
    Color color = DoodleColors.ink,
  }) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = color;

  static Paint fill(Color color) => Paint()
    ..style = PaintingStyle.fill
    ..color = color;

  /// A rounded rectangle whose edges wobble very slightly for a sketchy look.
  static Path roughRRect(Rect rect, double radius, {int seed = 0}) {
    final rng = Random(seed);
    double j() => (rng.nextDouble() - 0.5) * 1.6; // ±0.8px jitter

    final r = radius.clamp(0, min(rect.width, rect.height) / 2).toDouble();
    final path = Path();
    final l = rect.left, t = rect.top, rt = rect.right, b = rect.bottom;

    path.moveTo(l + r + j(), t + j());
    path.lineTo(rt - r + j(), t + j());
    path.quadraticBezierTo(rt + j(), t + j(), rt + j(), t + r + j());
    path.lineTo(rt + j(), b - r + j());
    path.quadraticBezierTo(rt + j(), b + j(), rt - r + j(), b + j());
    path.lineTo(l + r + j(), b + j());
    path.quadraticBezierTo(l + j(), b + j(), l + j(), b - r + j());
    path.lineTo(l + j(), t + r + j());
    path.quadraticBezierTo(l + j(), t + j(), l + r + j(), t + j());
    path.close();
    return path;
  }

  /// A wobbly circle approximated by a many-sided path.
  static Path roughCircle(Offset center, double radius, {int seed = 0}) {
    final rng = Random(seed);
    final path = Path();
    const segments = 22;
    for (var i = 0; i <= segments; i++) {
      final a = (i / segments) * 2 * pi;
      final wobble = 1 + (rng.nextDouble() - 0.5) * 0.06;
      final p = Offset(
        center.dx + cos(a) * radius * wobble,
        center.dy + sin(a) * radius * wobble,
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  /// A short hand-drawn line with a subtle mid-point bow.
  static Path roughLine(Offset a, Offset b, {double bow = 1.5}) {
    final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    final normal = Offset(-(b.dy - a.dy), b.dx - a.dx);
    final len = normal.distance == 0 ? 1.0 : normal.distance;
    final ctrl = mid + normal / len * bow;
    return Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, b.dx, b.dy);
  }
}
