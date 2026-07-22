import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme/doodle_colors.dart';

/// Lightweight doodle confetti: a handful of coloured sparks drift down once.
/// Skips animating when the platform requests reduced motion.
class DoodleConfetti extends StatefulWidget {
  const DoodleConfetti({super.key, this.pieces = 18});

  final int pieces;

  @override
  State<DoodleConfetti> createState() => _DoodleConfettiState();
}

class _DoodleConfettiState extends State<DoodleConfetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  final Random _rng = Random(7);
  late final List<_Piece> _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = List.generate(widget.pieces, (i) {
      return _Piece(
        x: _rng.nextDouble(),
        size: 6 + _rng.nextDouble() * 8,
        delay: _rng.nextDouble() * 0.4,
        drift: (_rng.nextDouble() - 0.5) * 0.3,
        color: _palette[i % _palette.length],
        rotations: 1 + _rng.nextDouble() * 2,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce) {
      _controller.value = 1;
    } else if (_controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    }
  }

  static const _palette = [
    DoodleColors.red,
    DoodleColors.blue,
    DoodleColors.yellow,
    DoodleColors.green,
    DoodleColors.orange,
  ];

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
          painter: _ConfettiPainter(_confetti, _controller.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.size,
    required this.delay,
    required this.drift,
    required this.color,
    required this.rotations,
  });
  final double x;
  final double size;
  final double delay;
  final double drift;
  final Color color;
  final double rotations;
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter(this.pieces, this.t);
  final List<_Piece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final dx = (p.x + p.drift * local) * size.width;
      final dy = local * size.height;
      final opacity = (1 - local).clamp(0.0, 1.0);
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(p.rotations * 2 * pi * local);
      final paint = Paint()..color = p.color.withValues(alpha: opacity);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
