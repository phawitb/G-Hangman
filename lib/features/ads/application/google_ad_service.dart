import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../domain/ad_config.dart';
import '../domain/interstitial_scheduler.dart';
import 'ad_service.dart';
import 'consent_manager.dart';

/// Real ad service backed by `google_mobile_ads`, with UMP consent, preloading,
/// cadence control and careful disposal.
class GoogleAdService implements AdService {
  GoogleAdService({
    ConsentManager? consentManager,
    InterstitialScheduler? scheduler,
  }) : _consent = consentManager ?? ConsentManager(),
       _scheduler = scheduler ?? InterstitialScheduler();

  final ConsentManager _consent;
  final InterstitialScheduler _scheduler;

  bool _initialized = false;
  bool _canRequestAds = false;

  RewardedAd? _rewardedAd;
  bool _rewardedLoading = false;

  InterstitialAd? _interstitialAd;
  bool _interstitialLoading = false;

  /// True while a full-screen ad is on screen — blocks stacking and rapid taps.
  bool _isShowingFullScreen = false;

  @override
  bool get canRequestAds => _canRequestAds;

  @override
  bool get isPrivacyOptionsRequired => _consent.isPrivacyOptionsRequired;

  @override
  bool get isRewardedReady => _rewardedAd != null;

  @override
  bool get isInterstitialReady => _interstitialAd != null;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await _consent.gatherConsent();
      _canRequestAds = await _consent.canRequestAds();
      await MobileAds.instance.initialize();
      if (_canRequestAds) {
        preloadRewarded();
        preloadInterstitial();
      }
    } catch (e) {
      debugPrint('GoogleAdService.initialize failed: $e');
    }
  }

  // ---- Rewarded -------------------------------------------------------------

  @override
  void preloadRewarded() {
    if (!_canRequestAds || _rewardedAd != null || _rewardedLoading) return;
    _rewardedLoading = true;
    RewardedAd.load(
      adUnitId: AdConfig.rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded failed to load: ${error.message}');
          _rewardedAd = null;
          _rewardedLoading = false;
        },
      ),
    );
  }

  @override
  Future<void> showRewarded({
    required VoidCallback onReward,
    VoidCallback? onUnavailable,
    VoidCallback? onClosed,
  }) async {
    if (_isShowingFullScreen) return; // guard rapid / duplicate taps
    final ad = _rewardedAd;
    if (ad == null) {
      onUnavailable?.call();
      preloadRewarded();
      return;
    }

    _isShowingFullScreen = true;
    // An interstitial must never follow a rewarded ad back-to-back.
    _scheduler.suppressNext();
    _rewardedAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isShowingFullScreen = false;
        preloadRewarded();
        onClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded failed to show: ${error.message}');
        ad.dispose();
        _isShowingFullScreen = false;
        preloadRewarded();
        onUnavailable?.call();
        onClosed?.call();
      },
    );

    await ad.show(
      onUserEarnedReward: (ad, reward) {
        // The one and only place a reward is ever granted.
        onReward();
      },
    );
  }

  // ---- Interstitial ---------------------------------------------------------

  @override
  void preloadInterstitial() {
    if (!_canRequestAds || _interstitialAd != null || _interstitialLoading) {
      return;
    }
    _interstitialLoading = true;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: ${error.message}');
          _interstitialAd = null;
          _interstitialLoading = false;
        },
      ),
    );
  }

  @override
  void registerLevelCompleted() => _scheduler.registerLevelCompleted();

  @override
  Future<bool> maybeShowInterstitial() async {
    if (_isShowingFullScreen || !_canRequestAds) return false;
    if (!_scheduler.consumeShouldShow()) return false;

    final ad = _interstitialAd;
    if (ad == null) {
      preloadInterstitial();
      return false;
    }

    _isShowingFullScreen = true;
    _interstitialAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isShowingFullScreen = false;
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial failed to show: ${error.message}');
        ad.dispose();
        _isShowingFullScreen = false;
        preloadInterstitial();
      },
    );
    await ad.show();
    return true;
  }

  // ---- Consent / lifecycle --------------------------------------------------

  @override
  Future<void> showPrivacyOptions() async {
    await _consent.showPrivacyOptionsForm();
    // Consent may now allow ads that were previously blocked.
    _canRequestAds = await _consent.canRequestAds();
    if (_canRequestAds) {
      preloadRewarded();
      preloadInterstitial();
    }
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
