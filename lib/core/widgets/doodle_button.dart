import 'package:flutter/material.dart';

import '../../app/theme/doodle_colors.dart';
import '../../app/theme/doodle_metrics.dart';
import '../../app/theme/doodle_text_styles.dart';
import 'doodle_box_painter.dart';

enum DoodleButtonVariant { primary, secondary, danger, success }

/// Chunky hand-drawn button with an offset shadow that the face sinks into when
/// pressed. Enforces a 48px minimum tap target and an obvious disabled state.
class DoodleButton extends StatefulWidget {
  const DoodleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = DoodleButtonVariant.primary,
    this.icon,
    this.expand = false,
    this.minHeight = 54,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final DoodleButtonVariant variant;
  final Widget? icon;
  final bool expand;
  final double minHeight;
  final String? semanticLabel;

  bool get enabled => onPressed != null;

  @override
  State<DoodleButton> createState() => _DoodleButtonState();
}

class _DoodleButtonState extends State<DoodleButton> {
  bool _pressed = false;

  Color get _fill {
    if (!widget.enabled) return DoodleColors.disabledFill;
    return switch (widget.variant) {
      DoodleButtonVariant.primary => DoodleColors.yellow,
      DoodleButtonVariant.secondary => DoodleColors.paper,
      DoodleButtonVariant.danger => DoodleColors.red,
      DoodleButtonVariant.success => DoodleColors.green,
    };
  }

  void _setPressed(bool value) {
    if (widget.enabled && _pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    const shadow = DoodleMetrics.shadowOffset;
    final activeShadow = widget.enabled && !_pressed ? shadow : Offset.zero;
    final faceShift = _pressed ? shadow : Offset.zero;

    final textColor = widget.enabled
        ? (widget.variant == DoodleButtonVariant.danger ||
                  widget.variant == DoodleButtonVariant.success
              ? DoodleColors.paper
              : DoodleColors.ink)
        : DoodleColors.disabledInk;

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DoodleMetrics.lg,
        vertical: DoodleMetrics.sm,
      ),
      child: Row(
        mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            widget.icon!,
            const SizedBox(width: DoodleMetrics.sm),
          ],
          Flexible(
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: DoodleTextStyles.button().copyWith(color: textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    Widget face = CustomPaint(
      painter: DoodleBoxPainter(
        fillColor: _fill,
        shadowOffset: activeShadow,
        strokeWidth: DoodleMetrics.strokeHeavy,
        seed: widget.label.hashCode & 0x3f,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: widget.minHeight,
          minWidth: DoodleMetrics.minTap,
        ),
        child: Center(child: content),
      ),
    );

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.semanticLabel ?? widget.label,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.enabled
            ? () {
                // Debounce is inherent: onTap only fires once per gesture.
                widget.onPressed!.call();
              }
            : null,
        child: AnimatedSlide(
          duration: DoodleMetrics.fast,
          offset: Offset(
            faceShift.dx / widget.minHeight,
            faceShift.dy / widget.minHeight,
          ),
          child: widget.expand
              ? SizedBox(width: double.infinity, child: face)
              : face,
        ),
      ),
    );
  }
}
