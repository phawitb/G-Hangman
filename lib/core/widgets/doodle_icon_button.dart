import 'package:flutter/material.dart';

import '../../app/theme/doodle_colors.dart';
import '../../app/theme/doodle_metrics.dart';
import 'doodle_icons.dart';
import 'hand_drawn.dart';

/// A circular hand-drawn icon button (settings gear, back, etc.).
class DoodleIconButton extends StatefulWidget {
  const DoodleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.size = 48,
    this.fill = DoodleColors.paper,
    this.iconFill,
  });

  final DoodleIconType icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final double size;
  final Color fill;
  final Color? iconFill;

  @override
  State<DoodleIconButton> createState() => _DoodleIconButtonState();
}

class _DoodleIconButtonState extends State<DoodleIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final size = widget.size < DoodleMetrics.minTap
        ? DoodleMetrics.minTap
        : widget.size;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: widget.onPressed,
        child: AnimatedScale(
          duration: DoodleMetrics.fast,
          scale: _pressed ? 0.92 : 1,
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _CirclePainter(
                fill: enabled ? widget.fill : DoodleColors.disabledFill,
              ),
              child: Center(
                child: DoodleIcon(
                  widget.icon,
                  size: size * 0.5,
                  fill: widget.iconFill,
                  ink: enabled ? DoodleColors.ink : DoodleColors.disabledInk,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  const _CirclePainter({required this.fill});
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 3;
    final path = HandDrawn.roughCircle(center, r, seed: 8);
    canvas.drawPath(path, HandDrawn.fill(fill));
    canvas.drawPath(
      path,
      HandDrawn.inkStroke(width: DoodleMetrics.strokeMedium),
    );
  }

  @override
  bool shouldRepaint(_CirclePainter old) => old.fill != fill;
}
