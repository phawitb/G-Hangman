/// Central economy configuration. All coin values live here so balancing the
/// game is a single-file change rather than a hunt for scattered literals.
abstract final class Economy {
  /// Coins granted to a brand-new player.
  static const int startingCoins = 150;

  /// Hint costs.
  static const int revealLetterCost = 30;
  static const int removeLettersCost = 40;
  static const int extraChanceCost = 50;

  /// How many wrong letters the "remove letters" hint clears at once.
  static const int removeLettersCount = 10;

  /// Extra Chance may only be purchased this many times per level.
  static const int maxExtraChancePerLevel = 1;

  /// Reward-chest tuning.
  static const int winsPerChest = 5;
  static const int chestRewardMin = 40;
  static const int chestRewardMax = 90;

  /// Daily-challenge completion bonus.
  static const int dailyRewardCoins = 60;

  /// Clamp so a balance can never go negative.
  static int clampBalance(int value) => value < 0 ? 0 : value;
}
