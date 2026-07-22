import '../../../data/seed_levels.dart';
import '../domain/game_level.dart';

/// Read-only access to the level catalogue. Kept behind an interface-ish class
/// so the source (bundled seed data today, remote later) can change without
/// touching callers.
class LevelRepository {
  const LevelRepository();

  List<GameLevel> get all => kSeedLevels;

  int get count => kSeedLevels.length;

  int get firstId => kSeedLevels.first.id;

  int get lastId => kSeedLevels.last.id;

  /// Returns the level with [id], or null when it does not exist.
  GameLevel? byId(int id) {
    for (final level in kSeedLevels) {
      if (level.id == id) return level;
    }
    return null;
  }

  /// The level that comes after [id], or null if [id] is the last one.
  GameLevel? nextAfter(int id) {
    final index = kSeedLevels.indexWhere((l) => l.id == id);
    if (index < 0 || index + 1 >= kSeedLevels.length) return null;
    return kSeedLevels[index + 1];
  }

  bool exists(int id) => byId(id) != null;
}
