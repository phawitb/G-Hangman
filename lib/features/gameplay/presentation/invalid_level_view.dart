import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/doodle_metrics.dart';
import '../../../app/theme/doodle_text_styles.dart';
import '../../../core/widgets/bottom_reserve.dart';
import '../../../core/widgets/doodle_button.dart';
import '../../../core/widgets/doodle_card.dart';
import '../../../core/widgets/doodle_icons.dart';
import '../../../core/widgets/notebook_background.dart';
import '../../localization/application/locale_controller.dart';
import '../../localization/domain/str_key.dart';

/// Friendly fallback shown when a level id is missing or still locked.
class InvalidLevelView extends ConsumerWidget {
  const InvalidLevelView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translateProvider);
    return Scaffold(
      body: NotebookBackground(
        child: SafeArea(
          child: BottomReserve(
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
                        t(StrKey.invalidTitle),
                        textAlign: TextAlign.center,
                        style: DoodleTextStyles.heading(),
                      ),
                      const SizedBox(height: DoodleMetrics.sm),
                      Text(
                        t(StrKey.invalidBody),
                        textAlign: TextAlign.center,
                        style: DoodleTextStyles.body(),
                      ),
                      const SizedBox(height: DoodleMetrics.xl),
                      DoodleButton(
                        label: t(StrKey.backToLevels),
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
      ),
    );
  }
}
