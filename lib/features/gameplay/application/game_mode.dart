/// Which flow a play session belongs to. Controls scoring side-effects.
enum GameMode {
  adventure,
  daily,
  twoPlayer;

  /// Coin-priced hints are only available where the player has a coin balance.
  bool get coinsEnabled => this != GameMode.twoPlayer;
}
