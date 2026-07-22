import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme/doodle_colors.dart';
import 'hand_drawn.dart';

/// The set of original hand-drawn glyphs used across the UI. All are painted
/// from scratch — no external image assets.
enum DoodleIconType {
  coin,
  heart,
  lock,
  chest,
  bulb,
  reveal,
  bomb,
  star,
  starOutline,
  sparkle,
  arrowRight,
  gear,
  back,
  cloud,
  logo,
}

/// Renders a [DoodleIconType] at [size] with an optional [fill] tint.
class DoodleIcon extends StatelessWidget {
  const DoodleIcon(
    this.type, {
    super.key,
    this.size = 24,
    this.fill,
    this.ink = DoodleColors.ink,
  });

  final DoodleIconType type;
  final double size;
  final Color? fill;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DoodleIconPainter(type: type, fill: fill, ink: ink),
      ),
    );
  }
}

class _DoodleIconPainter extends CustomPainter {
  _DoodleIconPainter({
    required this.type,
    required this.fill,
    required this.ink,
  });

  final DoodleIconType type;
  final Color? fill;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final s = min(size.width, size.height);
    final stroke = HandDrawn.inkStroke(width: s * 0.06, color: ink);
    switch (type) {
      case DoodleIconType.coin:
        _coin(canvas, s, stroke);
      case DoodleIconType.heart:
        _heart(canvas, s, stroke);
      case DoodleIconType.lock:
        _lock(canvas, s, stroke);
      case DoodleIconType.chest:
        _chest(canvas, s, stroke);
      case DoodleIconType.bulb:
        _bulb(canvas, s, stroke);
      case DoodleIconType.reveal:
        _reveal(canvas, s, stroke);
      case DoodleIconType.bomb:
        _bomb(canvas, s, stroke);
      case DoodleIconType.star:
        _star(canvas, s, stroke, filled: true);
      case DoodleIconType.starOutline:
        _star(canvas, s, stroke, filled: false);
      case DoodleIconType.sparkle:
        _sparkle(canvas, s, stroke);
      case DoodleIconType.arrowRight:
        _arrow(canvas, s, stroke);
      case DoodleIconType.gear:
        _gear(canvas, s, stroke);
      case DoodleIconType.back:
        _back(canvas, s, stroke);
      case DoodleIconType.cloud:
        _cloud(canvas, s, stroke);
      case DoodleIconType.logo:
        _logo(canvas, s, stroke);
    }
  }

  void _fillIf(Canvas c, Path p, Color? color) {
    if (color != null) c.drawPath(p, HandDrawn.fill(color));
  }

  void _coin(Canvas c, double s, Paint stroke) {
    final center = Offset(s / 2, s / 2);
    final outer = HandDrawn.roughCircle(center, s * 0.40, seed: 3);
    _fillIf(c, outer, fill ?? DoodleColors.yellow);
    c.drawPath(outer, stroke);
    c.drawPath(
      HandDrawn.roughCircle(center, s * 0.30, seed: 7),
      HandDrawn.inkStroke(width: s * 0.04, color: ink),
    );
    // little star in the middle
    _star(
      c,
      s,
      HandDrawn.inkStroke(width: s * 0.035, color: ink),
      filled: false,
      scale: 0.34,
      center: center,
    );
  }

  void _heart(Canvas c, double s, Paint stroke) {
    final p = Path();
    final w = s, h = s;
    p.moveTo(w * 0.5, h * 0.82);
    p.cubicTo(w * 0.05, h * 0.52, w * 0.12, h * 0.14, w * 0.5, h * 0.34);
    p.cubicTo(w * 0.88, h * 0.14, w * 0.95, h * 0.52, w * 0.5, h * 0.82);
    p.close();
    _fillIf(c, p, fill ?? DoodleColors.red);
    c.drawPath(p, stroke);
  }

  void _lock(Canvas c, double s, Paint stroke) {
    final body = HandDrawn.roughRRect(
      Rect.fromLTWH(s * 0.24, s * 0.44, s * 0.52, s * 0.40),
      s * 0.10,
      seed: 2,
    );
    _fillIf(c, body, fill ?? DoodleColors.paperDeep);
    c.drawPath(body, stroke);
    // shackle
    final shackle = Path()
      ..moveTo(s * 0.34, s * 0.44)
      ..lineTo(s * 0.34, s * 0.34)
      ..arcToPoint(
        Offset(s * 0.66, s * 0.34),
        radius: Radius.circular(s * 0.16),
      )
      ..lineTo(s * 0.66, s * 0.44);
    c.drawPath(shackle, stroke);
    // keyhole
    c.drawCircle(Offset(s * 0.5, s * 0.60), s * 0.05, HandDrawn.fill(ink));
  }

  void _chest(Canvas c, double s, Paint stroke) {
    final base = HandDrawn.roughRRect(
      Rect.fromLTWH(s * 0.16, s * 0.44, s * 0.68, s * 0.34),
      s * 0.06,
      seed: 5,
    );
    _fillIf(c, base, fill ?? DoodleColors.orange);
    c.drawPath(base, stroke);
    final lid = Path()
      ..moveTo(s * 0.16, s * 0.44)
      ..quadraticBezierTo(s * 0.5, s * 0.20, s * 0.84, s * 0.44)
      ..close();
    _fillIf(c, lid, fill ?? DoodleColors.orangeDeep);
    c.drawPath(lid, stroke);
    c.drawLine(Offset(s * 0.16, s * 0.56), Offset(s * 0.84, s * 0.56), stroke);
    // clasp
    c.drawRect(
      Rect.fromLTWH(s * 0.46, s * 0.50, s * 0.08, s * 0.12),
      HandDrawn.fill(DoodleColors.ink),
    );
  }

  void _bulb(Canvas c, double s, Paint stroke) {
    final bulb = HandDrawn.roughCircle(
      Offset(s * 0.5, s * 0.42),
      s * 0.26,
      seed: 9,
    );
    _fillIf(c, bulb, fill ?? DoodleColors.yellow);
    c.drawPath(bulb, stroke);
    // base
    c.drawLine(Offset(s * 0.40, s * 0.66), Offset(s * 0.60, s * 0.66), stroke);
    c.drawLine(Offset(s * 0.42, s * 0.74), Offset(s * 0.58, s * 0.74), stroke);
    c.drawLine(Offset(s * 0.45, s * 0.82), Offset(s * 0.55, s * 0.82), stroke);
    // filament
    c.drawLine(Offset(s * 0.44, s * 0.42), Offset(s * 0.50, s * 0.50), stroke);
    c.drawLine(Offset(s * 0.56, s * 0.42), Offset(s * 0.50, s * 0.50), stroke);
  }

  void _reveal(Canvas c, double s, Paint stroke) {
    final center = Offset(s * 0.44, s * 0.44);
    final glass = HandDrawn.roughCircle(center, s * 0.24, seed: 4);
    _fillIf(c, glass, fill ?? DoodleColors.blue.withValues(alpha: 0.25));
    c.drawPath(glass, stroke);
    c.drawLine(
      Offset(s * 0.62, s * 0.62),
      Offset(s * 0.82, s * 0.82),
      HandDrawn.inkStroke(width: s * 0.09, color: ink),
    );
  }

  void _bomb(Canvas c, double s, Paint stroke) {
    final body = HandDrawn.roughCircle(
      Offset(s * 0.46, s * 0.58),
      s * 0.30,
      seed: 6,
    );
    _fillIf(c, body, fill ?? DoodleColors.inkSoft);
    c.drawPath(body, stroke);
    // fuse
    final fuse = Path()
      ..moveTo(s * 0.62, s * 0.34)
      ..quadraticBezierTo(s * 0.78, s * 0.20, s * 0.70, s * 0.12);
    c.drawPath(fuse, stroke);
    _sparkle(c, s, stroke, center: Offset(s * 0.70, s * 0.10), scale: 0.28);
  }

  void _star(
    Canvas c,
    double s,
    Paint stroke, {
    required bool filled,
    double scale = 0.9,
    Offset? center,
  }) {
    final ctr = center ?? Offset(s / 2, s / 2);
    final rOuter = s * 0.5 * scale;
    final rInner = rOuter * 0.45;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? rOuter : rInner;
      final a = -pi / 2 + i * pi / 5;
      final p = Offset(ctr.dx + cos(a) * r, ctr.dy + sin(a) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    if (filled) _fillIf(c, path, fill ?? DoodleColors.yellow);
    c.drawPath(path, stroke);
  }

  void _sparkle(
    Canvas c,
    double s,
    Paint stroke, {
    Offset? center,
    double scale = 0.7,
  }) {
    final ctr = center ?? Offset(s / 2, s / 2);
    final r = s * 0.5 * scale;
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final rr = i.isEven ? r : r * 0.32;
      final a = -pi / 2 + i * pi / 4;
      final p = Offset(ctr.dx + cos(a) * rr, ctr.dy + sin(a) * rr);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    _fillIf(c, path, fill ?? DoodleColors.yellow);
    c.drawPath(path, stroke);
  }

  void _arrow(Canvas c, double s, Paint stroke) {
    c.drawPath(
      HandDrawn.roughLine(Offset(s * 0.20, s * 0.5), Offset(s * 0.78, s * 0.5)),
      stroke,
    );
    c.drawLine(Offset(s * 0.78, s * 0.5), Offset(s * 0.60, s * 0.34), stroke);
    c.drawLine(Offset(s * 0.78, s * 0.5), Offset(s * 0.60, s * 0.66), stroke);
  }

  void _back(Canvas c, double s, Paint stroke) {
    c.drawPath(
      HandDrawn.roughLine(Offset(s * 0.80, s * 0.5), Offset(s * 0.22, s * 0.5)),
      stroke,
    );
    c.drawLine(Offset(s * 0.22, s * 0.5), Offset(s * 0.40, s * 0.34), stroke);
    c.drawLine(Offset(s * 0.22, s * 0.5), Offset(s * 0.40, s * 0.66), stroke);
  }

  void _gear(Canvas c, double s, Paint stroke) {
    final center = Offset(s / 2, s / 2);
    final rOut = s * 0.40;
    final rIn = s * 0.30;
    final path = Path();
    const teeth = 8;
    for (var i = 0; i < teeth * 2; i++) {
      final r = i.isEven ? rOut : rIn;
      final a = i * pi / teeth;
      final p = Offset(center.dx + cos(a) * r, center.dy + sin(a) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    _fillIf(c, path, fill);
    c.drawPath(path, stroke);
    c.drawPath(HandDrawn.roughCircle(center, s * 0.14, seed: 1), stroke);
  }

  void _cloud(Canvas c, double s, Paint stroke) {
    final path = Path()
      ..moveTo(s * 0.24, s * 0.64)
      ..arcToPoint(
        Offset(s * 0.40, s * 0.44),
        radius: Radius.circular(s * 0.14),
      )
      ..arcToPoint(
        Offset(s * 0.66, s * 0.42),
        radius: Radius.circular(s * 0.18),
      )
      ..arcToPoint(
        Offset(s * 0.80, s * 0.64),
        radius: Radius.circular(s * 0.14),
      )
      ..close();
    _fillIf(c, path, fill ?? DoodleColors.paper);
    c.drawPath(path, stroke);
  }

  void _logo(Canvas c, double s, Paint stroke) {
    // Open book with a quill spark — the app's mark.
    final spine = Offset(s * 0.5, s * 0.30);
    final left = Path()
      ..moveTo(spine.dx, spine.dy)
      ..quadraticBezierTo(s * 0.24, s * 0.24, s * 0.12, s * 0.34)
      ..lineTo(s * 0.12, s * 0.72)
      ..quadraticBezierTo(s * 0.30, s * 0.62, spine.dx, s * 0.68)
      ..close();
    final right = Path()
      ..moveTo(spine.dx, spine.dy)
      ..quadraticBezierTo(s * 0.76, s * 0.24, s * 0.88, s * 0.34)
      ..lineTo(s * 0.88, s * 0.72)
      ..quadraticBezierTo(s * 0.70, s * 0.62, spine.dx, s * 0.68)
      ..close();
    _fillIf(c, left, fill ?? DoodleColors.paper);
    _fillIf(c, right, fill ?? DoodleColors.paper);
    c.drawPath(left, stroke);
    c.drawPath(right, stroke);
    c.drawLine(Offset(spine.dx, spine.dy), Offset(spine.dx, s * 0.68), stroke);
    _sparkle(
      c,
      s,
      HandDrawn.inkStroke(width: s * 0.04, color: DoodleColors.yellowDeep),
      center: Offset(s * 0.78, s * 0.22),
      scale: 0.30,
    );
  }

  @override
  bool shouldRepaint(_DoodleIconPainter old) =>
      old.type != type || old.fill != fill || old.ink != ink;
}
