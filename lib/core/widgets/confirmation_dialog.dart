import 'package:flutter/material.dart';

import '../../app/theme/doodle_metrics.dart';
import '../../app/theme/doodle_text_styles.dart';
import 'doodle_button.dart';
import 'doodle_card.dart';

/// Shows a hand-drawn confirmation dialog. Resolves to true only when the
/// player taps the confirm action.
Future<bool> showDoodleConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Yes',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black26,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(DoodleMetrics.xl),
      child: DoodleCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: DoodleTextStyles.heading(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DoodleMetrics.md),
            Text(
              message,
              style: DoodleTextStyles.body(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DoodleMetrics.xl),
            Row(
              children: [
                Expanded(
                  child: DoodleButton(
                    label: cancelLabel,
                    variant: DoodleButtonVariant.secondary,
                    expand: true,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: DoodleMetrics.md),
                Expanded(
                  child: DoodleButton(
                    label: confirmLabel,
                    variant: destructive
                        ? DoodleButtonVariant.danger
                        : DoodleButtonVariant.primary,
                    expand: true,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}
