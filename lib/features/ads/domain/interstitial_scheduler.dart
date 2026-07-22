import 'ad_config.dart';

/// Pure, side-effect-free policy for when an interstitial may be shown.
///
/// Rules enforced here (all unit-tested):
///  * only after every Nth completed level (default 4);
///  * never on level 0 (no completions yet);
///  * never immediately after a rewarded ad — one rewarded ad "suppresses" the
///    very next interstitial opportunity.
class InterstitialScheduler {
  InterstitialScheduler({this.everyN = AdConfig.interstitialEveryNLevels});

  final int everyN;

  int _completedLevels = 0;
  bool _suppressedByRewarded = false;

  int get completedLevels => _completedLevels;
  bool get isSuppressed => _suppressedByRewarded;

  /// Count one finished level toward the cadence.
  void registerLevelCompleted() => _completedLevels++;

  /// Mark that a rewarded ad was just shown, so the next interstitial is skipped.
  void suppressNext() => _suppressedByRewarded = true;

  /// Returns whether an interstitial should be shown *now*, consuming any
  /// pending rewarded-ad suppression. Call this at a natural break between
  /// levels — never during active gameplay.
  bool consumeShouldShow() {
    final eligible = _completedLevels > 0 && _completedLevels % everyN == 0;
    if (_suppressedByRewarded) {
      _suppressedByRewarded = false;
      return false;
    }
    return eligible;
  }

  void reset() {
    _completedLevels = 0;
    _suppressedByRewarded = false;
  }
}
