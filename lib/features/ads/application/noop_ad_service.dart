import 'package:flutter/foundation.dart';

import 'ad_service.dart';

/// Ad service used on the web and in automated tests: it never loads or shows
/// real ads, so gameplay stays fully functional without any ad inventory.
class NoopAdService implements AdService {
  @override
  Future<void> initialize() async {}

  @override
  bool get canRequestAds => false;

  @override
  bool get isPrivacyOptionsRequired => false;

  @override
  bool get isRewardedReady => false;

  @override
  bool get isInterstitialReady => false;

  @override
  void preloadRewarded() {}

  @override
  void preloadInterstitial() {}

  @override
  Future<void> showRewarded({
    required VoidCallback onReward,
    VoidCallback? onUnavailable,
    VoidCallback? onClosed,
  }) async {
    // No inventory: report unavailable, never grant a reward.
    onUnavailable?.call();
    onClosed?.call();
  }

  @override
  void registerLevelCompleted() {}

  @override
  Future<bool> maybeShowInterstitial() async => false;

  @override
  Future<void> showPrivacyOptions() async {}

  @override
  void dispose() {}
}
