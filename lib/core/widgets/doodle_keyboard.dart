import 'package:flutter/material.dart';

import '../../app/theme/doodle_colors.dart';
import '../../app/theme/doodle_metrics.dart';
import '../../app/theme/doodle_text_styles.dart';
import 'hand_drawn.dart';

/// An in-app, hand-drawn on-screen keyboard used instead of the system
/// keyboard. Supports A–Z, hyphen and space (which covers everything the app's
/// text fields accept), plus backspace and a done key.
class DoodleKeyboard extends StatelessWidget {
  const DoodleKeyboard({
    super.key,
    required this.onCharacter,
    required this.onBackspace,
    required this.onDone,
    this.alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
  });

  final ValueChanged<String> onCharacter;
  final VoidCallback onBackspace;
  final VoidCallback onDone;

  /// The letters to show (language-specific, incl. Ä Ö Ü Å).
  final String alphabet;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DoodleColors.paperDeep,
        border: Border(
          top: BorderSide(
            color: DoodleColors.ink,
            width: DoodleMetrics.strokeMedium,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        DoodleMetrics.sm,
        DoodleMetrics.sm,
        DoodleMetrics.sm,
        DoodleMetrics.sm,
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const columns = 8;
            const spacing = DoodleMetrics.xs;
            final keyW =
                ((constraints.maxWidth - spacing * (columns - 1)) / columns)
                    .clamp(28.0, 56.0);
            final keyH = keyW * 1.12;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final ch in alphabet.split(''))
                      _Key(
                        width: keyW,
                        height: keyH,
                        label: ch,
                        onTap: () => onCharacter(ch),
                      ),
                  ],
                ),
                const SizedBox(height: spacing),
                Row(
                  children: [
                    _Key(
                      width: keyW,
                      height: keyH,
                      label: '-',
                      onTap: () => onCharacter('-'),
                    ),
                    const SizedBox(width: spacing),
                    Expanded(
                      child: _Key(
                        height: keyH,
                        label: 'space',
                        onTap: () => onCharacter(' '),
                      ),
                    ),
                    const SizedBox(width: spacing),
                    _Key(
                      width: keyW * 1.4,
                      height: keyH,
                      icon: Icons.backspace_outlined,
                      semantic: 'Backspace',
                      onTap: onBackspace,
                    ),
                    const SizedBox(width: spacing),
                    _Key(
                      width: keyW * 1.4,
                      height: keyH,
                      icon: Icons.check,
                      semantic: 'Done',
                      fill: DoodleColors.yellow,
                      onTap: onDone,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Key extends StatefulWidget {
  const _Key({
    this.width,
    required this.height,
    this.label,
    this.icon,
    this.semantic,
    this.fill = DoodleColors.paper,
    required this.onTap,
  });

  final double? width;
  final double height;
  final String? label;
  final IconData? icon;
  final String? semantic;
  final Color fill;
  final VoidCallback onTap;

  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final child = SizedBox(
      width: widget.width,
      height: widget.height,
      child: CustomPaint(
        painter: _KeyPainter(fill: widget.fill),
        child: Center(
          child: widget.icon != null
              ? Icon(
                  widget.icon,
                  size: widget.height * 0.42,
                  color: DoodleColors.ink,
                )
              : Text(
                  widget.label!,
                  style: widget.label!.length > 1
                      ? DoodleTextStyles.label().copyWith(
                          color: DoodleColors.ink,
                        )
                      : DoodleTextStyles.keycap().copyWith(
                          fontSize: widget.height * 0.5,
                        ),
                ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: widget.semantic ?? widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: DoodleMetrics.fast,
          scale: _pressed ? 0.9 : 1,
          child: child,
        ),
      ),
    );
  }
}

class _KeyPainter extends CustomPainter {
  const _KeyPainter({required this.fill});
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    final path = HandDrawn.roughRRect(rect, DoodleMetrics.radiusSm, seed: 42);
    canvas.drawPath(path, HandDrawn.fill(fill));
    canvas.drawPath(
      path,
      HandDrawn.inkStroke(width: DoodleMetrics.strokeMedium),
    );
  }

  @override
  bool shouldRepaint(_KeyPainter old) => old.fill != fill;
}
