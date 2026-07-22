import 'package:flutter/material.dart';

import 'doodle_colors.dart';
import 'doodle_text_styles.dart';

/// Assembles a Material 3 [ThemeData] tuned to the notebook palette.
///
/// Material is used only as an internal scaffold; the visible chrome comes from
/// the custom doodle widgets. Keeping a real theme means default dialogs,
/// snackbars and text selection still look coherent.
abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DoodleColors.yellow,
        primary: DoodleColors.yellow,
        onPrimary: DoodleColors.ink,
        secondary: DoodleColors.blue,
        surface: DoodleColors.paper,
        onSurface: DoodleColors.ink,
        error: DoodleColors.red,
      ),
      scaffoldBackgroundColor: DoodleColors.paper,
      splashFactory: InkRipple.splashFactory,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: DoodleTextStyles.logo(),
        headlineMedium: DoodleTextStyles.heading(),
        titleLarge: DoodleTextStyles.title(),
        bodyLarge: DoodleTextStyles.body(),
        bodyMedium: DoodleTextStyles.bodySoft(),
        labelLarge: DoodleTextStyles.button(),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: DoodleColors.paper,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: DoodleColors.ink,
        contentTextStyle: TextStyle(color: DoodleColors.paper),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
