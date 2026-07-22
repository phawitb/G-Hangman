/// The kinds of reward a rewarded ad can grant, and their fixed amounts.
///
/// The actual granting always happens inside the ad SDK's
/// `onUserEarnedReward` callback (see the ad service) — opening or closing an
/// ad never grants anything on its own.
enum AdRewardType { coins, revealLetter, revive }

abstract final class AdRewards {
  /// Coins granted by the "watch an ad for coins" reward.
  static const int coinAmount = 50;

  /// Extra allowed mistakes granted by a "continue after losing" revive.
  static const int reviveExtraChances = 2;

  static String label(AdRewardType type) => switch (type) {
    AdRewardType.coins => 'Watch an ad for $coinAmount coins',
    AdRewardType.revealLetter => 'Watch an ad to reveal a letter',
    AdRewardType.revive => 'Watch an ad to keep playing',
  };
}
