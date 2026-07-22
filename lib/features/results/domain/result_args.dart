import '../../gameplay/application/game_mode.dart';
import '../../gameplay/domain/game_level.dart';
import '../../gameplay/domain/game_state.dart';

/// Data handed to the result screen after a session finishes.
class ResultArgs {
  const ResultArgs({
    required this.mode,
    required this.level,
    required this.finalState,
    required this.coinsEarned,
    this.nextLevelId,
    this.dailyStreak,
  });

  final GameMode mode;
  final GameLevel level;
  final GameState finalState;
  final int coinsEarned;

  /// The level to continue to (Adventure only); null when there is no next.
  final int? nextLevelId;

  /// Daily streak to celebrate (Daily mode only).
  final int? dailyStreak;

  bool get won => finalState.phase == GamePhase.won;
}
