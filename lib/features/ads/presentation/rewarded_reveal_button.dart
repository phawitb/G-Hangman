import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/doodle_button.dart';
import '../../../core/widgets/doodle_icons.dart';
import '../../gameplay/application/game_controller.dart';
import '../../gameplay/domain/game_state.dart';
import '../../gameplay/domain/hangman_engine.dart';
import '../application/ad_providers.dart';

/// "Watch an ad to reveal a letter" button, shown under the hint row only when
/// an ad can be requested and a letter is still hidden. Never mandatory.
class RewardedRevealButton extends ConsumerStatefulWidget {
  const RewardedRevealButton({super.key});

  @override
  ConsumerState<RewardedRevealButton> createState() =>
      _RewardedRevealButtonState();
}

class _RewardedRevealButtonState extends ConsumerState<RewardedRevealButton> {
  bool _busy = false;

  Future<void> _watch() async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    await ref
        .read(adServiceProvider)
        .showRewarded(
          onReward: () {
            ref.read(gameControllerProvider.notifier).revealLetterFromAd();
          },
          onUnavailable: () {
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('No ad available right now.')),
              );
          },
          onClosed: () {
            if (mounted) setState(() => _busy = false);
          },
        );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameControllerProvider);
    final canRequestAds = ref.watch(adServiceProvider).canRequestAds;
    final canReveal =
        state != null &&
        state.phase == GamePhase.playing &&
        HangmanEngine.canReveal(state);
    if (!canRequestAds || !canReveal) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: DoodleButton(
        label: _busy ? 'Loading ad…' : 'Reveal a letter — watch ad',
        variant: DoodleButtonVariant.secondary,
        expand: true,
        minHeight: 46,
        icon: const DoodleIcon(DoodleIconType.reveal, size: 20),
        onPressed: _busy ? null : _watch,
      ),
    );
  }
}
