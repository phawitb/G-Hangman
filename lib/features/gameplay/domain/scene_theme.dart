/// The animated danger scene shown for a level. Each theme has multiple visual
/// stages driven by the number of wrong guesses. All artwork is original and
/// drawn with [CustomPainter] (see `character_scene.dart`).
enum SceneTheme {
  /// Mascot drifts upward under a bunch of balloons; each mistake adds a
  /// balloon and a cheeky bird drifts closer.
  balloonDrift,

  /// Mascot hops across stepping stones over a puddle; each mistake sinks a
  /// stone a little further.
  steppingStones,

  /// Mascot balances a growing stack of books; each mistake adds a wobblier
  /// book to the tower.
  bookStack;

  String get label => switch (this) {
    SceneTheme.balloonDrift => 'Balloon Drift',
    SceneTheme.steppingStones => 'Stepping Stones',
    SceneTheme.bookStack => 'Book Stack',
  };

  /// Deterministic pick so a level always shows the same scene.
  static SceneTheme forSeed(int seed) =>
      SceneTheme.values[seed % SceneTheme.values.length];
}
