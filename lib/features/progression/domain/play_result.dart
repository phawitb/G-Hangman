/// Immutable summary of a finished Adventure play, handed to the progression
/// controller so it can update records, coins, streaks and chest progress.
class PlayResult {
  const PlayResult({
    required this.levelId,
    required this.won,
    required this.stars,
    required this.accuracy,
    required this.wrongGuesses,
    required this.baseCoinReward,
    required this.paidHintUsed,
  });

  final int levelId;
  final bool won;
  final int stars; // 0 on loss
  final double accuracy; // 0–1
  final int wrongGuesses;
  final int baseCoinReward;
  final bool paidHintUsed;

  bool get isPerfect => won && stars >= 3;
}
