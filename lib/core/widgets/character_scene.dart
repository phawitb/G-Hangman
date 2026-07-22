import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme/doodle_colors.dart';
import '../../features/gameplay/domain/game_state.dart';
import '../../features/gameplay/domain/scene_theme.dart';
import 'hand_drawn.dart';

/// Facial expressions for the mascot "Sketch".
enum _Mood { happy, neutral, worried, sad }

/// Animated scene showing the mascot in a light-hearted predicament that
/// intensifies with each wrong guess. All artwork is original CustomPainter
/// work — no external images.
class CharacterScene extends StatefulWidget {
  const CharacterScene({
    super.key,
    required this.theme,
    required this.wrongCount,
    required this.maxMistakes,
    required this.phase,
    this.aspectRatio = 1.7,
  });

  final SceneTheme theme;
  final int wrongCount;
  final int maxMistakes;
  final GamePhase phase;

  /// Width / height of the scene box. Larger = shorter scene.
  final double aspectRatio;

  @override
  State<CharacterScene> createState() => _CharacterSceneState();
}

class _CharacterSceneState extends State<CharacterScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect the "reduce motion" accessibility setting.
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce) {
      _bob.value = 0.5;
    } else if (!_bob.isAnimating) {
      _bob.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.maxMistakes == 0
        ? 0.0
        : (widget.wrongCount / widget.maxMistakes).clamp(0.0, 1.0);
    return Semantics(
      label: _describe(ratio),
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: AnimatedBuilder(
          animation: _bob,
          builder: (context, _) {
            final bob = sin(_bob.value * 2 * pi) * 4;
            return CustomPaint(
              painter: _ScenePainter(
                theme: widget.theme,
                ratio: ratio,
                wrongCount: widget.wrongCount,
                phase: widget.phase,
                bob: bob,
              ),
            );
          },
        ),
      ),
    );
  }

  String _describe(double ratio) {
    final where = switch (widget.theme) {
      SceneTheme.balloonDrift => 'holding balloons',
      SceneTheme.steppingStones => 'crossing stepping stones',
      SceneTheme.bookStack => 'balancing a stack of books',
    };
    if (widget.phase == GamePhase.won) return 'The mascot celebrates, $where.';
    if (widget.phase == GamePhase.lost) {
      return 'The mascot looks dizzy after too many wrong guesses, $where.';
    }
    return 'The mascot is $where. ${widget.wrongCount} wrong so far.';
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.theme,
    required this.ratio,
    required this.wrongCount,
    required this.phase,
    required this.bob,
  });

  final SceneTheme theme;
  final double ratio;
  final int wrongCount;
  final GamePhase phase;
  final double bob;

  _Mood get mood {
    if (phase == GamePhase.won) return _Mood.happy;
    if (phase == GamePhase.lost) return _Mood.sad;
    if (ratio >= 0.6) return _Mood.worried;
    return _Mood.neutral;
  }

  @override
  void paint(Canvas canvas, Size size) {
    switch (theme) {
      case SceneTheme.balloonDrift:
        _paintBalloons(canvas, size);
      case SceneTheme.steppingStones:
        _paintStones(canvas, size);
      case SceneTheme.bookStack:
        _paintBooks(canvas, size);
    }
  }

  // ---- Shared mascot --------------------------------------------------------

  void _drawMascot(
    Canvas canvas,
    Offset feet,
    double scale, {
    double armAngle = 0.6,
  }) {
    final ink = HandDrawn.inkStroke(width: 2.4 * scale);
    final headR = 16.0 * scale;
    final headCenter = Offset(feet.dx, feet.dy - 54 * scale);

    // Body
    final hip = Offset(feet.dx, feet.dy - 24 * scale);
    final neck = Offset(feet.dx, headCenter.dy + headR);
    canvas.drawLine(neck, hip, ink);
    // Legs
    canvas.drawLine(hip, Offset(feet.dx - 9 * scale, feet.dy), ink);
    canvas.drawLine(hip, Offset(feet.dx + 9 * scale, feet.dy), ink);
    // Arms (angle up when celebrating)
    final shoulder = Offset(feet.dx, neck.dy + 8 * scale);
    final ay = phase == GamePhase.won ? -1.0 : armAngle;
    canvas.drawLine(
      shoulder,
      Offset(shoulder.dx - 16 * scale, shoulder.dy + 14 * scale * ay),
      ink,
    );
    canvas.drawLine(
      shoulder,
      Offset(shoulder.dx + 16 * scale, shoulder.dy + 14 * scale * ay),
      ink,
    );

    // Head
    final head = HandDrawn.roughCircle(headCenter, headR, seed: 17);
    canvas.drawPath(head, HandDrawn.fill(DoodleColors.paper));
    canvas.drawPath(head, ink);
    _drawFace(canvas, headCenter, headR, scale, ink);
  }

  void _drawFace(Canvas canvas, Offset c, double r, double scale, Paint ink) {
    final eyeDx = r * 0.42;
    final eyeDy = -r * 0.1;
    final dot = HandDrawn.fill(DoodleColors.ink);
    if (mood == _Mood.sad) {
      // spiral-ish dizzy eyes -> small circles
      canvas.drawCircle(
        Offset(c.dx - eyeDx, c.dy + eyeDy),
        r * 0.16,
        HandDrawn.inkStroke(width: 1.6 * scale),
      );
      canvas.drawCircle(
        Offset(c.dx + eyeDx, c.dy + eyeDy),
        r * 0.16,
        HandDrawn.inkStroke(width: 1.6 * scale),
      );
    } else {
      canvas.drawCircle(Offset(c.dx - eyeDx, c.dy + eyeDy), r * 0.10, dot);
      canvas.drawCircle(Offset(c.dx + eyeDx, c.dy + eyeDy), r * 0.10, dot);
    }
    // Mouth
    final my = c.dy + r * 0.4;
    final mouth = switch (mood) {
      _Mood.happy => HandDrawn.roughLine(
        Offset(c.dx - r * 0.4, my - r * 0.1),
        Offset(c.dx + r * 0.4, my - r * 0.1),
        bow: 4 * scale,
      ),
      _Mood.neutral => HandDrawn.roughLine(
        Offset(c.dx - r * 0.3, my),
        Offset(c.dx + r * 0.3, my),
        bow: 1 * scale,
      ),
      _Mood.worried => HandDrawn.roughLine(
        Offset(c.dx - r * 0.3, my),
        Offset(c.dx + r * 0.3, my),
        bow: -2 * scale,
      ),
      _Mood.sad => HandDrawn.roughLine(
        Offset(c.dx - r * 0.35, my + r * 0.1),
        Offset(c.dx + r * 0.35, my + r * 0.1),
        bow: -4 * scale,
      ),
    };
    canvas.drawPath(mouth, ink);
  }

  // ---- Balloon drift --------------------------------------------------------

  void _paintBalloons(Canvas canvas, Size size) {
    final scale = size.height / 200;
    final groundY = size.height * 0.88;
    _ground(canvas, size, groundY);

    // The more mistakes, the higher the mascot floats.
    final lift = ratio * size.height * 0.22 + bob;
    final feet = Offset(size.width * 0.42, groundY - lift);
    _drawMascot(canvas, feet, scale);

    // Balloons grow in number with wrong guesses.
    final count = 1 + (ratio * 5).round();
    final anchor = Offset(feet.dx, feet.dy - 70 * scale);
    final palette = [
      DoodleColors.red,
      DoodleColors.blue,
      DoodleColors.yellow,
      DoodleColors.green,
      DoodleColors.orange,
    ];
    for (var i = 0; i < count; i++) {
      final spread = (i - count / 2) * 16 * scale;
      final bx = anchor.dx + spread;
      final by = anchor.dy - 34 * scale - (i.isEven ? 8 : 0) * scale;
      canvas.drawPath(
        HandDrawn.roughLine(anchor, Offset(bx, by), bow: 3),
        HandDrawn.inkStroke(width: 1.2 * scale),
      );
      final balloon = HandDrawn.roughCircle(
        Offset(bx, by),
        12 * scale,
        seed: i,
      );
      canvas.drawPath(balloon, HandDrawn.fill(palette[i % palette.length]));
      canvas.drawPath(balloon, HandDrawn.inkStroke(width: 2 * scale));
    }

    // A cheeky bird drifts closer as danger rises.
    final birdX = size.width * (0.95 - ratio * 0.5);
    final birdY = size.height * 0.22 + bob;
    _bird(canvas, Offset(birdX, birdY), scale);
  }

  void _bird(Canvas canvas, Offset c, double scale) {
    final ink = HandDrawn.inkStroke(width: 2 * scale);
    canvas.drawPath(
      HandDrawn.roughLine(
        Offset(c.dx - 10 * scale, c.dy),
        Offset(c.dx, c.dy - 6 * scale),
      ),
      ink,
    );
    canvas.drawPath(
      HandDrawn.roughLine(
        Offset(c.dx, c.dy - 6 * scale),
        Offset(c.dx + 10 * scale, c.dy),
      ),
      ink,
    );
  }

  // ---- Stepping stones ------------------------------------------------------

  void _paintStones(Canvas canvas, Size size) {
    final scale = size.height / 200;
    final waterY = size.height * 0.66;
    // Water
    final water = Paint()..color = DoodleColors.blue.withValues(alpha: 0.18);
    canvas.drawRect(
      Rect.fromLTWH(0, waterY, size.width, size.height - waterY),
      water,
    );
    for (var i = 0; i < 3; i++) {
      final wy = waterY + 10 * scale + i * 14 * scale + bob * 0.4;
      canvas.drawPath(
        _wave(size.width, wy, 12 * scale),
        HandDrawn.inkStroke(width: 1.4 * scale, color: DoodleColors.blueDeep),
      );
    }

    // Stones sink deeper with each mistake.
    final stoneCount = 4;
    for (var i = 0; i < stoneCount; i++) {
      final sx = size.width * (0.2 + i * 0.2);
      final sink = (i == 1 || i == 2) ? ratio * 14 * scale : 0.0;
      final sy = waterY - 4 * scale + sink;
      final rect = Rect.fromCenter(
        center: Offset(sx, sy),
        width: 40 * scale,
        height: 18 * scale,
      );
      final stone = HandDrawn.roughRRect(rect, 9 * scale, seed: i + 2);
      canvas.drawPath(stone, HandDrawn.fill(DoodleColors.paperDeep));
      canvas.drawPath(stone, HandDrawn.inkStroke(width: 2 * scale));
    }

    // Mascot stands on the second stone, wobbling with danger.
    final feet = Offset(
      size.width * 0.4,
      waterY - 12 * scale + ratio * 14 * scale,
    );
    _drawMascot(canvas, feet, scale, armAngle: ratio);
  }

  Path _wave(double width, double y, double amp) {
    final path = Path()..moveTo(0, y);
    for (double x = 0; x <= width; x += amp * 2) {
      path.relativeQuadraticBezierTo(amp, -amp * 0.6, amp * 2, 0);
    }
    return path;
  }

  // ---- Book stack -----------------------------------------------------------

  void _paintBooks(Canvas canvas, Size size) {
    final scale = size.height / 200;
    final groundY = size.height * 0.9;
    _ground(canvas, size, groundY);

    final cx = size.width * 0.5;
    final books = 1 + (ratio * 5).round();
    final palette = [
      DoodleColors.red,
      DoodleColors.green,
      DoodleColors.blue,
      DoodleColors.orange,
      DoodleColors.yellow,
    ];
    var y = groundY;
    final tilt = ratio * 0.06;
    for (var i = 0; i < books; i++) {
      final w = (54 - i * 3) * scale;
      final h = 14 * scale;
      final offsetX = sin(i * 1.3) * tilt * 60 * scale;
      final rect = Rect.fromCenter(
        center: Offset(cx + offsetX, y - h / 2),
        width: w,
        height: h,
      );
      final book = HandDrawn.roughRRect(rect, 3 * scale, seed: i + 5);
      canvas.drawPath(book, HandDrawn.fill(palette[i % palette.length]));
      canvas.drawPath(book, HandDrawn.inkStroke(width: 2 * scale));
      y -= h + 2 * scale;
    }

    // Mascot balances beside/atop the stack.
    final feet = Offset(cx + 46 * scale, groundY);
    _drawMascot(canvas, feet, scale * 0.9, armAngle: -0.4 - ratio);
  }

  // ---- Helpers --------------------------------------------------------------

  void _ground(Canvas canvas, Size size, double y) {
    canvas.drawPath(
      HandDrawn.roughLine(
        Offset(size.width * 0.05, y),
        Offset(size.width * 0.95, y),
        bow: 2,
      ),
      HandDrawn.inkStroke(width: 2.4),
    );
  }

  @override
  bool shouldRepaint(_ScenePainter old) =>
      old.theme != theme ||
      old.ratio != ratio ||
      old.wrongCount != wrongCount ||
      old.phase != phase ||
      old.bob != bob;
}
