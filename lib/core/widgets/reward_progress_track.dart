import 'package:flutter/material.dart';

import '../../app/theme/doodle_colors.dart';
import '../../app/theme/doodle_metrics.dart';
import 'doodle_icons.dart';
import 'hand_drawn.dart';

/// A row of pips filling toward a reward chest.
class RewardProgressTrack extends StatelessWidget {
  const RewardProgressTrack({
    super.key,
    required this.filled,
    required this.total,
    this.pipSize = 20,
  });

  final int filled;
  final int total;
  final double pipSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$filled of $total wins toward the reward chest',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < total; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: SizedBox(
                width: pipSize,
                height: pipSize,
                child: CustomPaint(painter: _PipPainter(on: i < filled)),
              ),
            ),
          const SizedBox(width: DoodleMetrics.sm),
          DoodleIcon(
            DoodleIconType.chest,
            size: pipSize * 1.6,
            fill: filled >= total
                ? DoodleColors.orange
                : DoodleColors.disabledFill,
            ink: filled >= total ? DoodleColors.ink : DoodleColors.disabledInk,
          ),
        ],
      ),
    );
  }
}

class _PipPainter extends CustomPainter {
  const _PipPainter({required this.on});
  final bool on;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final path = HandDrawn.roughCircle(
      center,
      size.shortestSide / 2 - 2,
      seed: 12,
    );
    canvas.drawPath(
      path,
      HandDrawn.fill(on ? DoodleColors.green : DoodleColors.paper),
    );
    canvas.drawPath(
      path,
      HandDrawn.inkStroke(width: DoodleMetrics.strokeMedium),
    );
  }

  @override
  bool shouldRepaint(_PipPainter old) => old.on != on;
}
