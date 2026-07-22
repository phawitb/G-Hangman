import 'package:flutter/material.dart';

import '../../app/theme/doodle_colors.dart';
import '../../app/theme/doodle_metrics.dart';
import '../../app/theme/doodle_text_styles.dart';
import 'doodle_box_painter.dart';
import 'doodle_icons.dart';

/// A hint control showing an icon, short label and coin cost. Disabled state is
/// clearly greyed so unaffordable/unavailable hints read as inactive.
class HintButton extends StatefulWidget {
  const HintButton({
    super.key,
    required this.icon,
    required this.label,
    required this.cost,
    required this.onPressed,
    this.affordable = true,
  });

  final DoodleIconType icon;
  final String label;
  final int cost;
  final VoidCallback? onPressed;
  final bool affordable;

  bool get enabled => onPressed != null;

  @override
  State<HintButton> createState() => _HintButtonState();
}

class _HintButtonState extends State<HintButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    final costColor = widget.affordable ? DoodleColors.ink : DoodleColors.red;
    return Semantics(
      button: true,
      enabled: enabled,
      label:
          '${widget.label}, costs ${widget.cost} coins'
          '${widget.affordable ? '' : ', not enough coins'}',
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: widget.onPressed,
        child: AnimatedScale(
          duration: DoodleMetrics.fast,
          scale: _pressed ? 0.94 : 1,
          child: CustomPaint(
            painter: DoodleBoxPainter(
              fillColor: enabled
                  ? DoodleColors.paper
                  : DoodleColors.disabledFill,
              radius: DoodleMetrics.radiusLg,
              strokeWidth: DoodleMetrics.strokeMedium,
              shadowOffset: enabled ? const Offset(2, 2.5) : Offset.zero,
              seed: widget.label.hashCode & 0x3f,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DoodleMetrics.sm,
                vertical: DoodleMetrics.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DoodleIcon(
                    widget.icon,
                    size: 30,
                    ink: enabled ? DoodleColors.ink : DoodleColors.disabledInk,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.label,
                    style: DoodleTextStyles.label().copyWith(
                      color: enabled
                          ? DoodleColors.ink
                          : DoodleColors.disabledInk,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DoodleIcon(DoodleIconType.coin, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        '${widget.cost}',
                        style: DoodleTextStyles.label().copyWith(
                          color: costColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
