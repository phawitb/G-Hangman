import 'package:flutter/material.dart';

/// Reserves an empty band at the bottom of a screen equal to [fraction] of the
/// screen height (default 15%), keeping content clear of the very bottom edge /
/// gesture-navigation area. [child] fills the remaining space above the band.
///
/// Place it directly inside a screen's [SafeArea]. Screens that already pin
/// their own bottom gap (e.g. the gameplay board) don't need this.
class BottomReserve extends StatelessWidget {
  const BottomReserve({super.key, required this.child, this.fraction = 0.15});

  final Widget child;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final gap = MediaQuery.sizeOf(context).height * fraction;
    return Column(
      children: [
        Expanded(child: child),
        SizedBox(height: gap),
      ],
    );
  }
}
