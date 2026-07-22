import '../domain/game_level.dart';

/// Read-only access to the (language-specific) level catalogue.
class LevelRepository {
  const LevelRepository(this.all);

  final List<GameLevel> all;

  int get count => all.length;

  int get firstId => all.isEmpty ? 1 : all.first.id;

  int get lastId => all.isEmpty ? 1 : all.last.id;

  /// Returns the level with [id], or null when it does not exist.
  GameLevel? byId(int id) {
    for (final level in all) {
      if (level.id == id) return level;
    }
    return null;
  }

  /// The level that comes after [id], or null if [id] is the last one.
  GameLevel? nextAfter(int id) {
    final index = all.indexWhere((l) => l.id == id);
    if (index < 0 || index + 1 >= all.length) return null;
    return all[index + 1];
  }

  bool exists(int id) => byId(id) != null;
}
