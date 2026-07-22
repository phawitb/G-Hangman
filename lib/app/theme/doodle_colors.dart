import 'package:flutter/painting.dart';

/// Central colour tokens for the hand-drawn notebook look.
///
/// All values are original design decisions inspired only by the broad
/// "warm paper + black ink + yellow highlight" language, not copied from any
/// existing product.
abstract final class DoodleColors {
  // Surfaces
  static const Color paper = Color(0xFFFAF9F3);
  static const Color paperDeep = Color(0xFFF1EFE4);
  static const Color gridLine = Color(0xFFDDDCD5);
  static const Color marginLine = Color(0xFFEBC9C2);

  // Ink
  static const Color ink = Color(0xFF171717);
  static const Color inkSoft = Color(0xFF4A4A46);
  static const Color inkFaint = Color(0xFF8C8C84);

  // Accents
  static const Color yellow = Color(0xFFFFD84D);
  static const Color yellowDeep = Color(0xFFE9B93A);
  static const Color green = Color(0xFF39C982);
  static const Color greenDeep = Color(0xFF2AA96B);
  static const Color red = Color(0xFFEF5C5C);
  static const Color redDeep = Color(0xFFD24444);
  static const Color blue = Color(0xFF3F8CFF);
  static const Color blueDeep = Color(0xFF2E6FD0);
  static const Color orange = Color(0xFFF5A623);
  static const Color orangeDeep = Color(0xFFD98910);

  // Semantic fills used behind ink strokes.
  static const Color shadow = Color(0x33171717);
  static const Color disabledFill = Color(0xFFE7E5DC);
  static const Color disabledInk = Color(0xFFB4B2A8);
}
