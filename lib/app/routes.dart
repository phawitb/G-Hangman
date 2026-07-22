/// Centralised route paths and names for GoRouter.
abstract final class AppRoutes {
  static const splash = '/';
  static const tutorial = '/tutorial';
  static const home = '/home';
  static const levels = '/levels';
  static const gamePattern = '/game/:levelId';
  static const result = '/result';
  static const twoPlayerSetup = '/two-player/setup';
  static const twoPlayerGame = '/two-player/game';
  static const daily = '/daily';
  static const settings = '/settings';
  static const privacy = '/privacy';
  static const terms = '/terms';

  static String game(int levelId) => '/game/$levelId';
}
