import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme/doodle_colors.dart';
import 'hand_drawn.dart';

/// A one-shot comic "boom" explosion, shown as a self-removing overlay. Used by
/// the "clear letters" hint just before the letters are blown off the keyboard.
abstract final class BombBurst {
  static void show(BuildContext context) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _BurstOverlay(onDone: () => entry.remove()),
    );
    overlay.insert(entry);
  }
}

class _BurstOverlay extends StatefulWidget {
  const _BurstOverlay({required this.onDone});
  final VoidCallback onDone;

  @override
  State<_BurstOverlay> createState() => _BurstOverlayState();
}

class _BurstOverlayState extends State<_BurstOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce) {
      // Respect reduced motion: skip the animation entirely.
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onDone());
      return;
    }
    _controller
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onDone();
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _BurstPainter(_controller.value),
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  const _BurstPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0) return;
    final center = size.center(Offset.zero);
    final maxR = size.shortestSide * 0.34;
    final grow = Curves.easeOutBack.transform(t.clamp(0.0, 1.0));
    final r = maxR * grow;
    // Pop in fast, fade out.
    final alpha = (sin(t * pi)).clamp(0.0, 1.0);

    // Comic starburst.
    const points = 14;
    final path = Path();
    for (var i = 0; i <= points * 2; i++) {
      final isOuter = i.isEven;
      final rr = isOuter ? r : r * 0.55;
      final a = -pi / 2 + i * pi / points + t * 0.6;
      final p = Offset(center.dx + cos(a) * rr, center.dy + sin(a) * rr);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      HandDrawn.fill(DoodleColors.orange.withValues(alpha: alpha * 0.85)),
    );
    canvas.drawPath(
      path,
      HandDrawn.fill(DoodleColors.yellow.withValues(alpha: alpha * 0.5)),
    );
    canvas.drawPath(
      path,
      HandDrawn.inkStroke(width: 3, color: DoodleColors.ink)
        ..color = DoodleColors.ink.withValues(alpha: alpha),
    );

    // Radiating spokes shooting outward.
    final spoke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = DoodleColors.ink.withValues(alpha: alpha);
    for (var i = 0; i < 8; i++) {
      final a = i * pi / 4 + t * 0.6;
      final inner = r * 1.05;
      final outer = r * (1.15 + 0.25 * grow);
      canvas.drawLine(
        center + Offset(cos(a) * inner, sin(a) * inner),
        center + Offset(cos(a) * outer, sin(a) * outer),
        spoke,
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t;
}
