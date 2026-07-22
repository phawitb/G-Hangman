import 'package:doodle_word_quest/core/persistence/key_value_store.dart';
import 'package:doodle_word_quest/core/providers.dart';
import 'package:doodle_word_quest/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('home screen renders title and menu buttons', (tester) async {
    // A tiny router so context.go targets resolve during the render.
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
        GoRoute(path: '/levels', builder: (_, _) => const SizedBox()),
        GoRoute(path: '/two-player/setup', builder: (_, _) => const SizedBox()),
        GoRoute(path: '/daily', builder: (_, _) => const SizedBox()),
        GoRoute(path: '/settings', builder: (_, _) => const SizedBox()),
        GoRoute(path: '/game/:id', builder: (_, _) => const SizedBox()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          keyValueStoreProvider.overrideWithValue(InMemoryKeyValueStore()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    // Let the staggered entrance animations (flutter_animate delays) complete
    // so no one-shot Timer is left pending at teardown.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Hangman Inky Words'), findsOneWidget);
    expect(find.text('Level Select'), findsOneWidget);
    expect(find.text('Two Player'), findsOneWidget);
    expect(find.text('Daily Challenge'), findsOneWidget);
  });
}
