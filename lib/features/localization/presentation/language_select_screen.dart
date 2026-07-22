import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/doodle_colors.dart';
import '../../../app/theme/doodle_metrics.dart';
import '../../../app/theme/doodle_text_styles.dart';
import '../../../core/widgets/bottom_reserve.dart';
import '../../../core/widgets/doodle_button.dart';
import '../../../core/widgets/doodle_icons.dart';
import '../../../core/widgets/notebook_background.dart';
import '../application/locale_controller.dart';
import '../domain/app_language.dart';
import '../domain/app_strings.dart';
import '../domain/str_key.dart';

/// First-launch language picker. Also reachable from Settings for a change.
class LanguageSelectScreen extends ConsumerWidget {
  const LanguageSelectScreen({super.key, this.fromSettings = false});

  /// When opened from Settings we return there; on first launch we route on.
  final bool fromSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeControllerProvider).language;

    Future<void> pick(AppLanguage lang) async {
      final controller = ref.read(localeControllerProvider.notifier);
      if (fromSettings) {
        await controller.setLanguage(lang);
        if (context.mounted) context.go(AppRoutes.settings);
      } else {
        await controller.choose(lang);
        if (context.mounted) context.go(AppRoutes.splash);
      }
    }

    return Scaffold(
      body: NotebookBackground(
        child: SafeArea(
          child: BottomReserve(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DoodleMetrics.lg),
              child: Column(
                children: [
                  const SizedBox(height: DoodleMetrics.lg),
                  const DoodleIcon(DoodleIconType.logo, size: 72),
                  const SizedBox(height: DoodleMetrics.md),
                  Text(
                    AppStrings.tr(current, StrKey.chooseLanguage),
                    textAlign: TextAlign.center,
                    style: DoodleTextStyles.heading(),
                  ),
                  const SizedBox(height: DoodleMetrics.xs),
                  Text(
                    AppStrings.tr(
                      current,
                      fromSettings
                          ? StrKey.chooseLanguageSub
                          : StrKey.changeLanguageAnytime,
                    ),
                    textAlign: TextAlign.center,
                    style: DoodleTextStyles.bodySoft(),
                  ),
                  const SizedBox(height: DoodleMetrics.xl),
                  for (final lang in AppLanguage.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: DoodleMetrics.md),
                      child: DoodleButton(
                        label: lang.nativeName,
                        variant: lang == current
                            ? DoodleButtonVariant.primary
                            : DoodleButtonVariant.secondary,
                        expand: true,
                        semanticLabel: lang.englishName,
                        onPressed: () => pick(lang),
                      ),
                    ),
                  const SizedBox(height: DoodleMetrics.lg),
                  Text(
                    'English · Deutsch · Svenska · Suomi',
                    style: DoodleTextStyles.label().copyWith(
                      color: DoodleColors.inkFaint,
                    ),
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
