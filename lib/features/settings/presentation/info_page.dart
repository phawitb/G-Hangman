import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/doodle_metrics.dart';
import '../../../app/theme/doodle_text_styles.dart';
import '../../../core/widgets/doodle_card.dart';
import '../../../core/widgets/doodle_icon_button.dart';
import '../../../core/widgets/doodle_icons.dart';
import '../../../core/widgets/notebook_background.dart';

/// Generic info page for the Privacy Policy and Terms routes.
///
/// The body text is a clearly-marked local placeholder — replace it with your
/// finalised policy before publishing. It intentionally does not pretend to be
/// finalised legal text.
class InfoPage extends StatelessWidget {
  const InfoPage({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
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
                      semanticLabel: 'Back to Settings',
                      size: 44,
                      onPressed: () => context.go(AppRoutes.settings),
                    ),
                    const SizedBox(width: DoodleMetrics.sm),
                    Expanded(
                      child: Text(title, style: DoodleTextStyles.heading()),
                    ),
                  ],
                ),
                const SizedBox(height: DoodleMetrics.lg),
                DoodleCard(child: Text(body, style: DoodleTextStyles.body())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const String kPrivacyPlaceholder =
    '[PLACEHOLDER — replace before release]\n\n'
    'Doodle Word Quest (version 1) is designed to run fully offline. It does '
    'not request internet, camera, contacts, location, microphone or storage '
    'permissions, and it does not collect, transmit or sell any personal data. '
    'All progress is stored locally on your device and can be erased at any '
    'time from Settings → Reset Progress.\n\n'
    'This text is a development placeholder. Insert your finalised privacy '
    'policy here before publishing to the App Store or Google Play.';

const String kTermsPlaceholder =
    '[PLACEHOLDER — replace before release]\n\n'
    'This app is provided for entertainment on an "as is" basis, without '
    'warranties of any kind. By playing, you agree to use it for personal, '
    'non-commercial enjoyment.\n\n'
    'This text is a development placeholder. Insert your finalised terms of use '
    'here before publishing.';
