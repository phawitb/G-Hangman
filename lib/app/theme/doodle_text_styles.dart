import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'doodle_colors.dart';

/// Typography tokens built on two open-source handwritten families:
///  * [GoogleFonts.kalam] — bold, playful display face for logo/headings.
///  * [GoogleFonts.patrickHand] — highly legible hand face for body/questions.
///
/// `google_fonts` caches fonts after first fetch and falls back to the platform
/// font when offline, so there is no hard dependency on a bundled `.ttf`.
abstract final class DoodleTextStyles {
  static TextStyle logo() => GoogleFonts.kalam(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: DoodleColors.ink,
    letterSpacing: 1.5,
    height: 1.05,
  );

  static TextStyle heading() => GoogleFonts.kalam(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: DoodleColors.ink,
    height: 1.1,
  );

  static TextStyle title() => GoogleFonts.patrickHand(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: DoodleColors.ink,
    height: 1.15,
  );

  static TextStyle question() => GoogleFonts.patrickHand(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: DoodleColors.ink,
    height: 1.3,
  );

  static TextStyle body() => GoogleFonts.patrickHand(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: DoodleColors.ink,
    height: 1.35,
  );

  static TextStyle bodySoft() => GoogleFonts.patrickHand(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: DoodleColors.inkSoft,
    height: 1.35,
  );

  static TextStyle button() => GoogleFonts.patrickHand(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: DoodleColors.ink,
    height: 1.1,
  );

  static TextStyle label() => GoogleFonts.patrickHand(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: DoodleColors.inkSoft,
    height: 1.1,
    letterSpacing: 0.5,
  );

  static TextStyle keycap() => GoogleFonts.kalam(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: DoodleColors.ink,
    height: 1.0,
  );

  static TextStyle counter() => GoogleFonts.kalam(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: DoodleColors.ink,
    height: 1.0,
  );
}
