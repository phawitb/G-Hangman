import 'package:flutter/material.dart';

import '../../app/theme/doodle_colors.dart';

/// Warm paper with a faint square grid and a soft margin rule, painted once and
/// reused behind every screen. Cheap to paint and repaints only when its inputs
/// change.
class NotebookBackground extends StatelessWidget {
  const NotebookBackground({super.key, this.child, this.cellSize = 26});

  final Widget? child;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NotebookPainter(cellSize: cellSize),
      child: child,
    );
  }
}

class _NotebookPainter extends CustomPainter {
  const _NotebookPainter({required this.cellSize});

  final double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = DoodleColors.paper);

    final grid = Paint()
      ..color = DoodleColors.gridLine
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y <= size.height; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // Soft left margin rule reminiscent of a school notebook.
    final margin = Paint()
      ..color = DoodleColors.marginLine
      ..strokeWidth = 1.5;
    final marginX = cellSize * 2;
    canvas.drawLine(Offset(marginX, 0), Offset(marginX, size.height), margin);
  }

  @override
  bool shouldRepaint(_NotebookPainter oldDelegate) =>
      oldDelegate.cellSize != cellSize;
}
