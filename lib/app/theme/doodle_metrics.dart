import 'package:flutter/animation.dart';

/// Spacing, stroke, radius, tap-target and duration tokens.
///
/// Keeping these centralised avoids the "magic numbers scattered everywhere"
/// anti-pattern and makes responsive tuning a one-file change.
abstract final class DoodleMetrics {
  // 8pt-ish spacing scale.
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Hand-drawn stroke weights (three-level hierarchy).
  static const double strokeHeavy = 3.2;
  static const double strokeMedium = 2.2;
  static const double strokeHair = 1.0;

  // Corner radii for the imperfect rounded rectangles.
  static const double radiusSm = 8;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 28;

  // Accessibility: minimum interactive size.
  static const double minTap = 48;

  // Drop-shadow offset used by doodle buttons/cards.
  static const Offset shadowOffset = Offset(3, 4);

  // Motion.
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration medium = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 460);
}
