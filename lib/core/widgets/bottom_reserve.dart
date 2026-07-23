import 'package:flutter/material.dart';

/// Historically reserved an empty band at the bottom of a screen. The app now
/// shows a shared banner footer at the very bottom of every screen, so content
/// simply sits directly above that ad frame — this no longer adds any gap and
/// is kept only so existing call sites don't need to change.
class BottomReserve extends StatelessWidget {
  const BottomReserve({super.key, required this.child, this.fraction = 0.15});

  final Widget child;

  /// Retained for API compatibility; no longer used.
  final double fraction;

  @override
  Widget build(BuildContext context) => child;
}
