import 'package:flutter/material.dart';

import '../../app/theme/doodle_metrics.dart';
import '../../app/theme/doodle_text_styles.dart';
import 'doodle_icons.dart';
import 'notebook_background.dart';

/// Full-screen paper loading state with a gently spinning sparkle.
class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({super.key, this.message = 'Sharpening pencils…'});

  final String message;

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotebookBackground(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotationTransition(
              turns: _controller,
              child: const DoodleIcon(DoodleIconType.sparkle, size: 56),
            ),
            const SizedBox(height: DoodleMetrics.lg),
            Text(widget.message, style: DoodleTextStyles.title()),
          ],
        ),
      ),
    );
  }
}
