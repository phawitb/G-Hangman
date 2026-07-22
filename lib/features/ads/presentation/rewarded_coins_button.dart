import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/doodle_button.dart';
import '../../../core/widgets/doodle_icons.dart';
import '../../progression/application/progress_controller.dart';
import '../application/ad_providers.dart';
import '../domain/ad_reward.dart';

/// "Watch an ad for coins" button. Hidden when ads can't be requested (web,
/// tests, or before consent resolves), so it never appears where it can't work.
class RewardedCoinsButton extends ConsumerStatefulWidget {
  const RewardedCoinsButton({super.key});

  @override
  ConsumerState<RewardedCoinsButton> createState() =>
      _RewardedCoinsButtonState();
}

class _RewardedCoinsButtonState extends ConsumerState<RewardedCoinsButton> {
  bool _busy = false;

  Future<void> _watch() async {
    if (_busy) return; // guard rapid repeated taps
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    await ref
        .read(adServiceProvider)
        .showRewarded(
          onReward: () {
            // Granted only inside the SDK's onUserEarnedReward callback.
            ref
                .read(progressControllerProvider.notifier)
                .addCoins(AdRewards.coinAmount);
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
    final canShow = ref.watch(adServiceProvider).canRequestAds;
    if (!canShow) return const SizedBox.shrink();
    return DoodleButton(
      label: _busy ? 'Loading ad…' : 'Free ${AdRewards.coinAmount} coins',
      variant: DoodleButtonVariant.secondary,
      expand: true,
      icon: const DoodleIcon(DoodleIconType.coin, size: 22),
      onPressed: _busy ? null : _watch,
    );
  }
}
