import 'package:flutter/foundation.dart';

/// Abstraction over the ad SDK so the rest of the app never imports
/// `google_mobile_ads` directly. Tests and web use [NoopAdService]; devices use
/// `GoogleAdService`.
abstract interface class AdService {
  /// Requests consent, initialises the SDK and preloads ads when allowed.
  /// Safe to call multiple times; only the first call does work.
  Future<void> initialize();

  /// Whether the user's consent state permits requesting ads.
  bool get canRequestAds;

  /// Whether a "Privacy options" entry point should be shown in Settings.
  bool get isPrivacyOptionsRequired;

  bool get isRewardedReady;
  bool get isInterstitialReady;

  /// Ask the SDK to (re)load a rewarded / interstitial ad. No-op when a request
  /// is already in flight or consent is missing.
  void preloadRewarded();
  void preloadInterstitial();

  /// Shows a rewarded ad. [onReward] runs **only** inside the SDK's
  /// `onUserEarnedReward` callback. [onUnavailable] runs when no ad could be
  /// shown so the caller can fall back gracefully.
  Future<void> showRewarded({
    required VoidCallback onReward,
    VoidCallback? onUnavailable,
    VoidCallback? onClosed,
  });

  /// Count a completed level toward the interstitial cadence.
  void registerLevelCompleted();

  /// Shows an interstitial if the cadence allows it and one is ready.
  /// Returns true when an ad was actually shown. Never throws.
  Future<bool> maybeShowInterstitial();

  /// Presents the UMP privacy options form (from a Settings entry point).
  Future<void> showPrivacyOptions();

  void dispose();
}
