import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/loading_overlay.dart';
import '../features/daily/presentation/daily_screen.dart';
import '../features/gameplay/domain/game_level.dart';
import '../features/gameplay/presentation/game_screen.dart';
import '../features/gameplay/presentation/invalid_level_view.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/level_select/presentation/level_select_screen.dart';
import '../features/localization/application/locale_controller.dart';
import '../features/localization/presentation/language_select_screen.dart';
import '../features/results/domain/result_args.dart';
import '../features/results/presentation/result_screen.dart';
import '../features/settings/application/settings_controller.dart';
import '../features/settings/presentation/info_page.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/tutorial/presentation/tutorial_screen.dart';
import '../features/two_player/presentation/two_player_game_screen.dart';
import '../features/two_player/presentation/two_player_setup_screen.dart';
import 'routes.dart';

/// Builds the app router. Kept in a provider so redirects can read settings.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        redirect: (context, state) {
          // First launch: choose a language, then the tutorial, then home.
          final chosen = ref.read(localeControllerProvider).chosen;
          if (!chosen) return AppRoutes.language;
          final done = ref.read(settingsControllerProvider).tutorialCompleted;
          return done ? AppRoutes.home : AppRoutes.tutorial;
        },
        builder: (context, state) => const LoadingOverlay(),
      ),
      GoRoute(
        path: AppRoutes.language,
        builder: (context, state) => LanguageSelectScreen(
          fromSettings: state.uri.queryParameters['from'] == 'settings',
        ),
      ),
      GoRoute(
        path: AppRoutes.tutorial,
        builder: (context, state) => const TutorialScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.levels,
        builder: (context, state) => const LevelSelectScreen(),
      ),
      GoRoute(
        path: AppRoutes.gamePattern,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['levelId'] ?? '');
          if (id == null) return const InvalidLevelView();
          return GameScreen(levelId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.result,
        redirect: (context, state) =>
            state.extra is ResultArgs ? null : AppRoutes.home,
        builder: (context, state) =>
            ResultScreen(args: state.extra as ResultArgs),
      ),
      GoRoute(
        path: AppRoutes.twoPlayerSetup,
        builder: (context, state) => const TwoPlayerSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.twoPlayerGame,
        redirect: (context, state) =>
            state.extra is GameLevel ? null : AppRoutes.twoPlayerSetup,
        builder: (context, state) =>
            TwoPlayerGameScreen(level: state.extra as GameLevel),
      ),
      GoRoute(
        path: AppRoutes.daily,
        builder: (context, state) => const DailyScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (context, state) =>
            const InfoPage(title: 'Privacy Policy', body: kPrivacyPlaceholder),
      ),
      GoRoute(
        path: AppRoutes.terms,
        builder: (context, state) =>
            const InfoPage(title: 'Terms of Use', body: kTermsPlaceholder),
      ),
    ],
    errorBuilder: (context, state) => const _RouteError(),
  );
});

class _RouteError extends StatelessWidget {
  const _RouteError();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => GoRouter.of(context).go(AppRoutes.home),
          child: const Text('Page not found. Tap to go home.'),
        ),
      ),
    );
  }
}
