import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/doodle_colors.dart';
import '../../../app/theme/doodle_metrics.dart';
import '../../../app/theme/doodle_text_styles.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/doodle_icon_button.dart';
import '../../../core/widgets/doodle_icons.dart';
import '../../../core/widgets/hand_drawn.dart';
import '../../../core/widgets/notebook_background.dart';
import '../../ads/presentation/banner_ad_widget.dart';
import '../../gameplay/domain/game_level.dart';
import '../../localization/application/locale_controller.dart';
import '../../localization/domain/str_key.dart';
import '../../progression/application/progress_controller.dart';
import '../../progression/domain/player_progress.dart';

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressControllerProvider);
    final levels = ref.watch(levelRepositoryProvider).all;
    final t = ref.watch(translateProvider);

    return Scaffold(
      body: NotebookBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(DoodleMetrics.lg),
                child: Row(
                  children: [
                    DoodleIconButton(
                      icon: DoodleIconType.back,
                      semanticLabel: t(StrKey.back),
                      size: 44,
                      onPressed: () => context.go(AppRoutes.home),
                    ),
                    const SizedBox(width: DoodleMetrics.sm),
                    Text(
                      t(StrKey.levelSelectTitle),
                      style: DoodleTextStyles.heading(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _LevelMap(levels: levels, progress: progress),
              ),
              // Banner footer pinned to the very bottom (zero-size until loaded).
              const BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

/// A winding, hand-drawn "adventure map": nodes zig-zag down the page joined by
/// a dashed trail, each with a category label, coloured underline and a little
/// themed doodle. Deliberately a touch asymmetric so it feels sketched by hand.
class _LevelMap extends StatelessWidget {
  const _LevelMap({required this.levels, required this.progress});

  final List<GameLevel> levels;
  final PlayerProgress progress;

  static const double _nodeSize = 84;
  static const double _rowH = 156;
  static const double _topPad = 28;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final r = _nodeSize / 2;

        // Node centres: alternate sides with a small deterministic wobble.
        final centers = <Offset>[
          for (var i = 0; i < levels.length; i++)
            Offset(_fracX(i) * w, _topPad + r + i * _rowH),
        ];
        final totalHeight = _topPad + _nodeSize + (levels.length - 1) * _rowH + 96;

        final children = <Widget>[
          // Dashed trail sits behind everything.
          Positioned.fill(
            child: CustomPaint(painter: _TrailPainter(centers: centers)),
          ),
        ];

        for (var i = 0; i < levels.length; i++) {
          final level = levels[i];
          final c = centers[i];
          final unlocked = progress.isUnlocked(level.id);
          final stars = progress.starsFor(level.id);
          final isCurrent =
              level.id == progress.unlockedLevelId && stars == 0;
          final onLeft = _fracX(i) < 0.5;

          // Node circle.
          children.add(
            Positioned(
              left: c.dx - r,
              top: c.dy - r,
              width: _nodeSize,
              height: _nodeSize,
              child: _NodeCircle(
                level: level,
                unlocked: unlocked,
                isCurrent: isCurrent,
              ),
            ),
          );

          // Label + underline + doodle, on the empty side beside the node.
          const labelW = 168.0;
          final label = _Label(
            category: level.category,
            unlocked: unlocked,
            stars: stars,
            alignToNodeRight: !onLeft, // node on right -> label hugs its left
            accent: _accentFor(level.category),
            motif: _motifFor(level.category),
          );
          if (onLeft) {
            children.add(
              Positioned(
                left: c.dx + r + 12,
                top: c.dy - 34,
                width: labelW,
                child: label,
              ),
            );
          } else {
            children.add(
              Positioned(
                right: w - (c.dx - r - 12),
                top: c.dy - 34,
                width: labelW,
                child: label,
              ),
            );
          }

          // Sparkles hugging the current node, plus a light scatter elsewhere.
          if (isCurrent) {
            children.add(_deco(c.dx - r + 2, c.dy - r - 14,
                const DoodleIcon(DoodleIconType.sparkle, size: 24)));
            children.add(_deco(c.dx + r - 16, c.dy - r - 24,
                const DoodleIcon(DoodleIconType.sparkle, size: 15)));
          } else if (i.isOdd) {
            // A tiny accent on the outer side of some locked nodes.
            final accentX = onLeft ? c.dx - r - 22 : c.dx + r + 4;
            children.add(_deco(
              accentX,
              c.dy - r + 4,
              DoodleIcon(
                i % 3 == 0
                    ? DoodleIconType.sparkle
                    : DoodleIconType.starOutline,
                size: 16,
                fill: DoodleColors.disabledFill,
                ink: DoodleColors.inkFaint,
              ),
            ));
          }
        }

        return SingleChildScrollView(
          child: SizedBox(
            width: w,
            height: totalHeight,
            child: Stack(clipBehavior: Clip.none, children: children),
          ),
        );
      },
    );
  }

  Widget _deco(double left, double top, Widget child) =>
      Positioned(left: left, top: top, child: IgnorePointer(child: child));

  /// Horizontal centre as a fraction of width — a gentle zig-zag that stays
  /// close to the middle, with a little deterministic wobble so it's not
  /// perfectly symmetric.
  double _fracX(int i) {
    final base = i.isEven ? 0.42 : 0.58;
    final jitter = sin(i * 2.3) * 0.05;
    return (base + jitter).clamp(0.36, 0.64);
  }

  static Color _accentFor(String category) {
    final k = category.toLowerCase();
    if (k.contains('animal')) return DoodleColors.orange;
    if (k.contains('nature')) return DoodleColors.green;
    if (k.contains('food')) return DoodleColors.red;
    if (k.contains('geograph')) return DoodleColors.greenDeep;
    if (k.contains('scien')) return DoodleColors.blue;
    if (k.contains('object')) return DoodleColors.blue;
    if (k.contains('sport')) return DoodleColors.orange;
    return DoodleColors.yellowDeep;
  }

  static _Motif _motifFor(String category) {
    final k = category.toLowerCase();
    if (k.contains('animal')) return _Motif.paw;
    if (k.contains('nature')) return _Motif.leaf;
    if (k.contains('food')) return _Motif.apple;
    if (k.contains('geograph')) return _Motif.mountain;
    if (k.contains('scien')) return _Motif.flask;
    if (k.contains('object')) return _Motif.clip;
    if (k.contains('sport')) return _Motif.ball;
    return _Motif.star;
  }
}

/// The dashed trail connecting the node centres with smooth vertical S-curves.
class _TrailPainter extends CustomPainter {
  const _TrailPainter({required this.centers});
  final List<Offset> centers;

  @override
  void paint(Canvas canvas, Size size) {
    if (centers.length < 2) return;
    final path = Path()..moveTo(centers.first.dx, centers.first.dy);
    for (var i = 1; i < centers.length; i++) {
      final p0 = centers[i - 1];
      final p1 = centers[i];
      final midY = (p0.dy + p1.dy) / 2;
      path.cubicTo(p0.dx, midY, p1.dx, midY, p1.dx, p1.dy);
    }
    final dashed = _dash(path, dash: 9, gap: 8);
    canvas.drawPath(
      dashed,
      HandDrawn.inkStroke(width: 2.4, color: DoodleColors.inkSoft),
    );
  }

  Path _dash(Path source, {required double dash, required double gap}) {
    final out = Path();
    for (final metric in source.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final len = min(dash, metric.length - dist);
        out.addPath(metric.extractPath(dist, dist + len), Offset.zero);
        dist += dash + gap;
      }
    }
    return out;
  }

  @override
  bool shouldRepaint(_TrailPainter old) => old.centers != centers;
}

class _NodeCircle extends StatelessWidget {
  const _NodeCircle({
    required this.level,
    required this.unlocked,
    required this.isCurrent,
  });

  final GameLevel level;
  final bool unlocked;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final fill = !unlocked
        ? DoodleColors.disabledFill
        : isCurrent
        ? DoodleColors.yellow
        : DoodleColors.paper;
    return Semantics(
      button: unlocked,
      label: unlocked
          ? 'Level ${level.id}, ${level.category}'
          : 'Level ${level.id}, locked',
      child: GestureDetector(
        onTap: unlocked ? () => context.go(AppRoutes.game(level.id)) : null,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(
              color: unlocked ? DoodleColors.ink : DoodleColors.disabledInk,
              width: isCurrent ? 3.4 : 2.4,
            ),
            boxShadow: const [
              BoxShadow(
                color: DoodleColors.shadow,
                offset: Offset(2, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: unlocked
              ? Text(
                  '${level.id}',
                  style: DoodleTextStyles.keycap().copyWith(fontSize: 26),
                )
              : const DoodleIcon(DoodleIconType.lock, size: 30),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({
    required this.category,
    required this.unlocked,
    required this.stars,
    required this.alignToNodeRight,
    required this.accent,
    required this.motif,
  });

  final String category;
  final bool unlocked;
  final int stars;

  /// When true the label sits to the LEFT of its node, so it hugs the right.
  final bool alignToNodeRight;
  final Color accent;
  final _Motif motif;

  @override
  Widget build(BuildContext context) {
    final cross = alignToNodeRight
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    final textBlock = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: cross,
        children: [
          Text(
            category,
            style: DoodleTextStyles.body().copyWith(
              fontSize: 18,
              color: unlocked ? DoodleColors.ink : DoodleColors.inkSoft,
            ),
          ),
          const SizedBox(height: 3),
          CustomPaint(
            size: const Size(double.infinity, 6),
            painter: _Underline(
              color: unlocked ? accent : accent.withValues(alpha: 0.45),
            ),
          ),
          if (unlocked) ...[
            const SizedBox(height: 4),
            _stars(stars),
          ],
        ],
      ),
    );

    // Doodles keep their category colour even when locked, for a lively map.
    final doodle = _CategoryDoodle(motif: motif, color: accent, size: 30);

    final rowChildren = alignToNodeRight
        ? [doodle, const SizedBox(width: 8), Flexible(child: textBlock)]
        : [Flexible(child: textBlock), const SizedBox(width: 8), doodle];

    return Align(
      alignment: alignToNodeRight
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: rowChildren,
      ),
    );
  }

  Widget _stars(int stars) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final earned = i < stars;
        return DoodleIcon(
          earned ? DoodleIconType.star : DoodleIconType.starOutline,
          size: 14,
          fill: earned ? DoodleColors.yellow : DoodleColors.disabledFill,
          ink: earned ? DoodleColors.ink : DoodleColors.disabledInk,
        );
      }),
    );
  }
}

class _Underline extends CustomPainter {
  const _Underline({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      HandDrawn.roughLine(
        Offset(2, size.height - 2),
        Offset(size.width - 2, size.height - 3),
        bow: 1.5,
      ),
      HandDrawn.inkStroke(width: 3.4, color: color),
    );
  }

  @override
  bool shouldRepaint(_Underline old) => old.color != color;
}

// ---------------------------------------------------------------------------
// Themed doodles
// ---------------------------------------------------------------------------

enum _Motif { paw, leaf, mountain, flask, clip, ball, apple, star }

class _CategoryDoodle extends StatelessWidget {
  const _CategoryDoodle({
    required this.motif,
    required this.color,
    this.size = 28,
  });

  final _Motif motif;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MotifPainter(motif: motif, color: color)),
    );
  }
}

class _MotifPainter extends CustomPainter {
  _MotifPainter({required this.motif, required this.color});
  final _Motif motif;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = min(size.width, size.height);
    final ink = HandDrawn.inkStroke(width: s * 0.07, color: color);
    switch (motif) {
      case _Motif.paw:
        _paw(canvas, s, ink);
      case _Motif.leaf:
        _leaf(canvas, s, ink);
      case _Motif.mountain:
        _mountain(canvas, s, ink);
      case _Motif.flask:
        _flask(canvas, s, ink);
      case _Motif.clip:
        _clip(canvas, s, ink);
      case _Motif.ball:
        _ball(canvas, s, ink);
      case _Motif.apple:
        _apple(canvas, s, ink);
      case _Motif.star:
        _starMotif(canvas, s, ink);
    }
  }

  void _paw(Canvas c, double s, Paint ink) {
    final fill = HandDrawn.fill(color);
    // main pad
    c.drawPath(
      HandDrawn.roughRRect(
        Rect.fromLTWH(s * 0.30, s * 0.50, s * 0.40, s * 0.34),
        s * 0.16,
        seed: 3,
      ),
      fill,
    );
    // toes
    for (final dx in [0.24, 0.42, 0.60, 0.78]) {
      final dy = (dx == 0.42 || dx == 0.60) ? 0.30 : 0.40;
      c.drawCircle(Offset(s * dx, s * dy), s * 0.08, fill);
    }
  }

  void _leaf(Canvas c, double s, Paint ink) {
    final path = Path()
      ..moveTo(s * 0.24, s * 0.76)
      ..quadraticBezierTo(s * 0.20, s * 0.30, s * 0.72, s * 0.22)
      ..quadraticBezierTo(s * 0.74, s * 0.66, s * 0.24, s * 0.76)
      ..close();
    c.drawPath(path, HandDrawn.fill(color.withValues(alpha: 0.30)));
    c.drawPath(path, ink);
    c.drawLine(Offset(s * 0.28, s * 0.72), Offset(s * 0.66, s * 0.30), ink);
  }

  void _mountain(Canvas c, double s, Paint ink) {
    final base = Path()
      ..moveTo(s * 0.12, s * 0.78)
      ..lineTo(s * 0.44, s * 0.30)
      ..lineTo(s * 0.62, s * 0.56)
      ..lineTo(s * 0.76, s * 0.38)
      ..lineTo(s * 0.92, s * 0.78)
      ..close();
    c.drawPath(base, HandDrawn.fill(color.withValues(alpha: 0.22)));
    c.drawPath(base, ink);
    // snow cap
    final cap = Path()
      ..moveTo(s * 0.36, s * 0.39)
      ..lineTo(s * 0.44, s * 0.30)
      ..lineTo(s * 0.52, s * 0.39)
      ..quadraticBezierTo(s * 0.44, s * 0.34, s * 0.36, s * 0.39)
      ..close();
    c.drawPath(cap, HandDrawn.fill(DoodleColors.paper));
  }

  void _flask(Canvas c, double s, Paint ink) {
    final body = Path()
      ..moveTo(s * 0.40, s * 0.20)
      ..lineTo(s * 0.40, s * 0.44)
      ..lineTo(s * 0.22, s * 0.78)
      ..quadraticBezierTo(s * 0.20, s * 0.86, s * 0.30, s * 0.86)
      ..lineTo(s * 0.70, s * 0.86)
      ..quadraticBezierTo(s * 0.80, s * 0.86, s * 0.78, s * 0.78)
      ..lineTo(s * 0.60, s * 0.44)
      ..lineTo(s * 0.60, s * 0.20);
    c.drawPath(body, ink);
    // liquid
    final liquid = Path()
      ..moveTo(s * 0.33, s * 0.62)
      ..lineTo(s * 0.67, s * 0.62)
      ..lineTo(s * 0.72, s * 0.78)
      ..quadraticBezierTo(s * 0.74, s * 0.84, s * 0.66, s * 0.84)
      ..lineTo(s * 0.34, s * 0.84)
      ..quadraticBezierTo(s * 0.26, s * 0.84, s * 0.28, s * 0.78)
      ..close();
    c.drawPath(liquid, HandDrawn.fill(color.withValues(alpha: 0.40)));
    // mouth
    c.drawLine(Offset(s * 0.36, s * 0.20), Offset(s * 0.64, s * 0.20), ink);
  }

  void _clip(Canvas c, double s, Paint ink) {
    final outer = Path()
      ..moveTo(s * 0.40, s * 0.24)
      ..lineTo(s * 0.40, s * 0.74)
      ..arcToPoint(Offset(s * 0.60, s * 0.74), radius: Radius.circular(s * 0.10))
      ..lineTo(s * 0.60, s * 0.34)
      ..arcToPoint(Offset(s * 0.44, s * 0.34),
          radius: Radius.circular(s * 0.08), clockwise: false)
      ..lineTo(s * 0.44, s * 0.66);
    c.drawPath(outer, ink);
  }

  void _ball(Canvas c, double s, Paint ink) {
    final center = Offset(s * 0.5, s * 0.52);
    c.drawPath(
      HandDrawn.roughCircle(center, s * 0.30, seed: 4),
      HandDrawn.fill(color.withValues(alpha: 0.22)),
    );
    c.drawPath(HandDrawn.roughCircle(center, s * 0.30, seed: 4), ink);
    c.drawLine(Offset(s * 0.20, s * 0.52), Offset(s * 0.80, s * 0.52), ink);
    c.drawArc(
      Rect.fromCircle(center: Offset(s * 0.5, s * 0.20), radius: s * 0.34),
      0.3,
      2.5,
      false,
      ink,
    );
  }

  void _apple(Canvas c, double s, Paint ink) {
    final body = HandDrawn.roughCircle(Offset(s * 0.5, s * 0.56), s * 0.28, seed: 8);
    c.drawPath(body, HandDrawn.fill(color.withValues(alpha: 0.30)));
    c.drawPath(body, ink);
    // stem
    c.drawLine(Offset(s * 0.5, s * 0.32), Offset(s * 0.56, s * 0.20), ink);
    // leaf
    final leaf = Path()
      ..moveTo(s * 0.56, s * 0.22)
      ..quadraticBezierTo(s * 0.74, s * 0.16, s * 0.70, s * 0.32)
      ..quadraticBezierTo(s * 0.60, s * 0.30, s * 0.56, s * 0.22)
      ..close();
    c.drawPath(leaf, HandDrawn.fill(DoodleColors.green.withValues(alpha: 0.6)));
  }

  void _starMotif(Canvas c, double s, Paint ink) {
    final ctr = Offset(s * 0.5, s * 0.5);
    final rOuter = s * 0.34;
    final rInner = rOuter * 0.45;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? rOuter : rInner;
      final a = -pi / 2 + i * pi / 5;
      final p = Offset(ctr.dx + cos(a) * r, ctr.dy + sin(a) * r);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    c.drawPath(path, HandDrawn.fill(color.withValues(alpha: 0.30)));
    c.drawPath(path, ink);
  }

  @override
  bool shouldRepaint(_MotifPainter old) =>
      old.motif != motif || old.color != color;
}
