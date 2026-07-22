import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/doodle_colors.dart';
import '../../../app/theme/doodle_metrics.dart';
import '../../../app/theme/doodle_text_styles.dart';
import '../../../core/constants/app_info.dart';
import '../../../core/widgets/doodle_button.dart';
import '../../../core/widgets/doodle_card.dart';
import '../../../core/widgets/doodle_icon_button.dart';
import '../../../core/widgets/doodle_icons.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/notebook_background.dart';
import '../../ads/application/ad_providers.dart';
import '../../daily/application/daily_controller.dart';
import '../../progression/application/progress_controller.dart';
import '../application/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _resetProgress(BuildContext context, WidgetRef ref) async {
    final first = await showDoodleConfirm(
      context,
      title: 'Reset all progress?',
      message:
          'This clears levels, stars, coins, streaks and the daily challenge.',
      confirmLabel: 'Continue',
      destructive: true,
    );
    if (!first || !context.mounted) return;
    final second = await showDoodleConfirm(
      context,
      title: 'Are you absolutely sure?',
      message: 'This cannot be undone. Start completely fresh?',
      confirmLabel: 'Reset everything',
      destructive: true,
    );
    if (!second || !context.mounted) return;
    await ref.read(progressControllerProvider.notifier).resetAll();
    await ref.read(dailyControllerProvider.notifier).resetAll();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Progress reset. Fresh start!')),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      body: NotebookBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DoodleMetrics.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DoodleIconButton(
                      icon: DoodleIconType.back,
                      semanticLabel: 'Back to Home',
                      size: 44,
                      onPressed: () => context.go(AppRoutes.home),
                    ),
                    const SizedBox(width: DoodleMetrics.sm),
                    Text('Settings', style: DoodleTextStyles.heading()),
                  ],
                ),
                const SizedBox(height: DoodleMetrics.lg),
                DoodleCard(
                  child: Column(
                    children: [
                      _toggle(
                        'Sound effects',
                        settings.soundEnabled,
                        controller.setSound,
                      ),
                      const Divider(),
                      _toggle(
                        'Background music',
                        settings.musicEnabled,
                        controller.setMusic,
                      ),
                      const Divider(),
                      _toggle(
                        'Vibration',
                        settings.hapticsEnabled,
                        controller.setHaptics,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DoodleMetrics.lg),
                DoodleButton(
                  label: 'Replay Tutorial',
                  variant: DoodleButtonVariant.secondary,
                  expand: true,
                  onPressed: () async {
                    await controller.replayTutorial();
                    if (context.mounted) context.go(AppRoutes.tutorial);
                  },
                ),
                const SizedBox(height: DoodleMetrics.md),
                _link(context, 'Privacy Policy', AppRoutes.privacy),
                const SizedBox(height: DoodleMetrics.md),
                _link(context, 'Terms of Use', AppRoutes.terms),
                if (ref.watch(adServiceProvider).isPrivacyOptionsRequired) ...[
                  const SizedBox(height: DoodleMetrics.md),
                  DoodleButton(
                    label: 'Privacy Choices',
                    variant: DoodleButtonVariant.secondary,
                    expand: true,
                    onPressed: () =>
                        ref.read(adServiceProvider).showPrivacyOptions(),
                  ),
                ],
                const SizedBox(height: DoodleMetrics.md),
                DoodleButton(
                  label: 'Reset Progress',
                  variant: DoodleButtonVariant.danger,
                  expand: true,
                  onPressed: () => _resetProgress(context, ref),
                ),
                const SizedBox(height: DoodleMetrics.xl),
                Center(
                  child: Column(
                    children: [
                      Text(
                        '${AppInfo.name} v${AppInfo.version}',
                        style: DoodleTextStyles.label(),
                      ),
                      const SizedBox(height: DoodleMetrics.xs),
                      Text(
                        AppInfo.credits,
                        textAlign: TextAlign.center,
                        style: DoodleTextStyles.label().copyWith(
                          color: DoodleColors.inkFaint,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DoodleMetrics.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(child: Text(label, style: DoodleTextStyles.body())),
        Switch(
          value: value,
          activeTrackColor: DoodleColors.green,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _link(BuildContext context, String label, String route) {
    return DoodleButton(
      label: label,
      variant: DoodleButtonVariant.secondary,
      expand: true,
      onPressed: () => context.go(route),
    );
  }
}
