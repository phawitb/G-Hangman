import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/doodle_metrics.dart';
import '../../../app/theme/doodle_text_styles.dart';
import '../../../core/widgets/doodle_button.dart';
import '../../../core/widgets/doodle_card.dart';
import '../../../core/widgets/doodle_icons.dart';
import '../../../core/widgets/notebook_background.dart';

/// Friendly fallback shown when a level id is missing or still locked.
class InvalidLevelView extends StatelessWidget {
  const InvalidLevelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotebookBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(DoodleMetrics.xl),
              child: DoodleCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const DoodleIcon(DoodleIconType.lock, size: 56),
                    const SizedBox(height: DoodleMetrics.md),
                    Text(
                      'That page ran off the paper',
                      textAlign: TextAlign.center,
                      style: DoodleTextStyles.heading(),
                    ),
                    const SizedBox(height: DoodleMetrics.sm),
                    Text(
                      "This level isn't available yet. Let's head back and pick another.",
                      textAlign: TextAlign.center,
                      style: DoodleTextStyles.body(),
                    ),
                    const SizedBox(height: DoodleMetrics.xl),
                    DoodleButton(
                      label: 'Back to Levels',
                      expand: true,
                      onPressed: () => context.go(AppRoutes.levels),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
