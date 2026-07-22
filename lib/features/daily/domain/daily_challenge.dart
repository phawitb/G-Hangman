import '../../gameplay/domain/game_level.dart';

/// Deterministically selects the level for a given calendar day.
///
/// No server is involved: the selection is a pure function of the date and the
/// level list, so every device shows the same daily challenge.
abstract final class DailyChallenge {
  /// Days since the Unix epoch (UTC-normalised to the local calendar day).
  static int _dayIndex(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    return local.difference(DateTime(1970)).inDays;
  }

  static GameLevel forDate(DateTime date, List<GameLevel> levels) {
    assert(levels.isNotEmpty, 'Level list must not be empty');
    final index = _dayIndex(date) % levels.length;
    return levels[index];
  }
}
