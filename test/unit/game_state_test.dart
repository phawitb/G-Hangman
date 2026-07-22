import 'package:doodle_word_quest/core/constants/game_config.dart';
import 'package:doodle_word_quest/features/gameplay/domain/difficulty.dart';
import 'package:doodle_word_quest/features/gameplay/domain/game_level.dart';
import 'package:doodle_word_quest/features/gameplay/domain/game_state.dart';
import 'package:doodle_word_quest/features/gameplay/domain/hangman_engine.dart';
import 'package:flutter_test/flutter_test.dart';

GameLevel _level(String answer) => GameLevel(
  id: 1,
  category: 'Test',
  clue: 'c',
  answer: answer,
  difficulty: Difficulty.easy,
  maxMistakes: 6,
);

void main() {
  group('stars', () {
    test('3 stars with no mistakes and no hints', () {
      var s = GameState.initial(_level('AB'));
      s = HangmanEngine.guess(s, 'A');
      s = HangmanEngine.guess(s, 'B');
      expect(s.stars, 3);
    });

    test('2 stars with up to two mistakes and no paid hint', () {
      var s = GameState.initial(_level('AB'));
      s = HangmanEngine.guess(s, 'X');
      s = HangmanEngine.guess(s, 'A');
      s = HangmanEngine.guess(s, 'B');
      expect(s.stars, 2);
    });

    test('1 star when a paid hint is used', () {
      var s = GameState.initial(_level('AB'));
      s = HangmanEngine.revealLetter(s); // paid hint
      s = HangmanEngine.guess(s, 'B');
      expect(s.stars, 1);
    });
  });

  test('GameConfig.starsFor thresholds', () {
    expect(
      GameConfig.starsFor(
        wrongGuesses: 0,
        anyHintUsed: false,
        paidHintUsed: false,
      ),
      3,
    );
    expect(
      GameConfig.starsFor(
        wrongGuesses: 2,
        anyHintUsed: false,
        paidHintUsed: false,
      ),
      2,
    );
    expect(
      GameConfig.starsFor(
        wrongGuesses: 5,
        anyHintUsed: false,
        paidHintUsed: false,
      ),
      1,
    );
  });

  test('accuracy reflects correct vs total guesses', () {
    var s = GameState.initial(_level('AB'));
    s = HangmanEngine.guess(s, 'A'); // correct
    s = HangmanEngine.guess(s, 'X'); // wrong
    expect(s.accuracy, closeTo(0.5, 0.0001));
  });

  test('remainingMistakes never negative', () {
    var s = GameState.initial(_level('A'));
    for (final l in ['B', 'C', 'D', 'E', 'F', 'G', 'H']) {
      s = HangmanEngine.guess(s, l);
    }
    expect(s.remainingMistakes, 0);
  });
}
