import 'package:doodle_word_quest/core/persistence/key_value_store.dart';
import 'package:doodle_word_quest/core/providers.dart';
import 'package:doodle_word_quest/core/widgets/notebook_background.dart';
import 'package:doodle_word_quest/features/gameplay/application/game_controller.dart';
import 'package:doodle_word_quest/features/gameplay/application/game_mode.dart';
import 'package:doodle_word_quest/features/gameplay/domain/difficulty.dart';
import 'package:doodle_word_quest/features/gameplay/domain/game_level.dart';
import 'package:doodle_word_quest/features/gameplay/domain/game_state.dart';
import 'package:doodle_word_quest/features/gameplay/presentation/game_play_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

const _level = GameLevel(
  id: 1,
  category: 'Test',
  clue: 'A four legged pet that barks',
  answer: 'BOOK',
  difficulty: Difficulty.easy,
  maxMistakes: 6,
);

ProviderContainer _startedContainer() {
  final container = ProviderContainer(
    overrides: [
      keyValueStoreProvider.overrideWithValue(InMemoryKeyValueStore()),
    ],
  );
  addTearDown(container.dispose);
  container
      .read(gameControllerProvider.notifier)
      .start(_level, mode: GameMode.adventure);
  return container;
}

Widget _wrap(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      home: Scaffold(
        body: NotebookBackground(
          child: GamePlayView(title: 'Level 1', onBack: () {}),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('renders clue and keyboard', (tester) async {
    final container = _startedContainer();
    await tester.pumpWidget(_wrap(container));
    await tester.pump();

    expect(find.text('A four legged pet that barks'), findsOneWidget);
    // All 26 letters exist somewhere in the keyboard.
    expect(find.text('B'), findsWidgets);
  });

  testWidgets('tapping a correct letter reveals it', (tester) async {
    final container = _startedContainer();
    await tester.pumpWidget(_wrap(container));
    await tester.pump();

    await tester.tap(find.text('O').first);
    await tester.pump();

    final state = container.read(gameControllerProvider)!;
    expect(state.isCorrectGuess('O'), isTrue);
    expect(state.wrongCount, 0);
  });

  testWidgets('tapping a wrong letter increases mistakes', (tester) async {
    final container = _startedContainer();
    await tester.pumpWidget(_wrap(container));
    await tester.pump();

    await tester.tap(find.text('Z').first);
    await tester.pump();

    expect(container.read(gameControllerProvider)!.wrongCount, 1);
  });

  testWidgets('a used letter cannot be guessed twice', (tester) async {
    final container = _startedContainer();
    await tester.pumpWidget(_wrap(container));
    await tester.pump();

    await tester.tap(find.text('Z').first);
    await tester.pump();
    final countAfterFirst = container
        .read(gameControllerProvider)!
        .guessed
        .length;

    await tester.tap(find.text('Z').first);
    await tester.pump();
    expect(
      container.read(gameControllerProvider)!.guessed.length,
      countAfterFirst,
    );
  });

  testWidgets('winning reveals the whole word', (tester) async {
    final container = _startedContainer();
    await tester.pumpWidget(_wrap(container));
    await tester.pump();

    for (final letter in ['B', 'O', 'K']) {
      await tester.tap(find.text(letter).first);
      await tester.pump();
    }
    expect(container.read(gameControllerProvider)!.phase, GamePhase.won);
  });

  testWidgets('no overflow on a small phone screen', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final container = _startedContainer();
    await tester.pumpWidget(_wrap(container));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
