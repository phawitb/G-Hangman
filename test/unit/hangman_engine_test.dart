import 'package:doodle_word_quest/features/gameplay/domain/difficulty.dart';
import 'package:doodle_word_quest/features/gameplay/domain/game_level.dart';
import 'package:doodle_word_quest/features/gameplay/domain/game_state.dart';
import 'package:doodle_word_quest/features/gameplay/domain/hangman_engine.dart';
import 'package:doodle_word_quest/features/gameplay/domain/hint_type.dart';
import 'package:flutter_test/flutter_test.dart';

GameLevel _level({String answer = 'BOOK', int maxMistakes = 6}) => GameLevel(
  id: 1,
  category: 'Test',
  clue: 'clue',
  answer: answer,
  difficulty: Difficulty.easy,
  maxMistakes: maxMistakes,
);

void main() {
  group('guess', () {
    test('correct guess reveals all occurrences', () {
      var s = GameState.initial(_level());
      s = HangmanEngine.guess(s, 'O');
      expect(s.maskedCharacters, [null, 'O', 'O', null]);
      expect(s.wrongCount, 0);
    });

    test('wrong guess increments mistakes', () {
      var s = GameState.initial(_level());
      s = HangmanEngine.guess(s, 'Z');
      expect(s.wrongCount, 1);
      expect(s.isWrongGuess('Z'), isTrue);
    });

    test('duplicate guess is ignored', () {
      var s = GameState.initial(_level());
      s = HangmanEngine.guess(s, 'Z');
      final before = s.guessed.length;
      s = HangmanEngine.guess(s, 'Z');
      expect(s.guessed.length, before);
    });

    test('lower-case input is normalised', () {
      var s = GameState.initial(_level());
      s = HangmanEngine.guess(s, 'b');
      expect(s.isCorrectGuess('B'), isTrue);
    });

    test('non-letter input is ignored', () {
      var s = GameState.initial(_level());
      s = HangmanEngine.guess(s, '5');
      expect(s.guessed, isEmpty);
    });
  });

  group('win / loss', () {
    test('win when all letters revealed', () {
      var s = GameState.initial(_level());
      for (final l in ['B', 'O', 'K']) {
        s = HangmanEngine.guess(s, l);
      }
      expect(s.phase, GamePhase.won);
      expect(s.isFinished, isTrue);
    });

    test('loss after max mistakes', () {
      var s = GameState.initial(_level(maxMistakes: 3));
      for (final l in ['X', 'Y', 'Z']) {
        s = HangmanEngine.guess(s, l);
      }
      expect(s.phase, GamePhase.lost);
      expect(s.remainingMistakes, 0);
    });

    test('no guesses accepted after finish', () {
      var s = GameState.initial(_level());
      for (final l in ['B', 'O', 'K']) {
        s = HangmanEngine.guess(s, l);
      }
      final after = HangmanEngine.guess(s, 'Z');
      expect(after.wrongCount, 0);
    });
  });

  group('reveal hint', () {
    test('reveals the next hidden letter and marks paid hint', () {
      var s = GameState.initial(_level());
      s = HangmanEngine.revealLetter(s);
      expect(s.guessed.contains('B'), isTrue);
      expect(s.paidHintUsed, isTrue);
      expect(s.revealHintCount, 1);
    });

    test('canReveal false when solved', () {
      var s = GameState.initial(_level(answer: 'AB'));
      s = HangmanEngine.guess(s, 'A');
      s = HangmanEngine.guess(s, 'B');
      expect(HangmanEngine.canReveal(s), isFalse);
    });
  });

  group('remove-letters hint', () {
    test('removes wrong letters from the keyboard', () {
      var s = GameState.initial(_level());
      s = HangmanEngine.removeLetters(s);
      expect(s.removedByHint.length, 3);
      // Removed letters must not be part of the answer.
      for (final l in s.removedByHint) {
        expect(s.requiredLetters.contains(l), isFalse);
      }
    });
  });

  group('extra-chance hint', () {
    test('adds one allowed mistake, once only', () {
      var s = GameState.initial(_level(maxMistakes: 3));
      s = HangmanEngine.extraChance(s);
      expect(s.maxMistakes, 4);
      expect(HangmanEngine.canExtraChance(s), isFalse);
      final again = HangmanEngine.extraChance(s);
      expect(again.maxMistakes, 4);
    });
  });

  test('canApply matches individual predicates', () {
    final s = GameState.initial(_level());
    expect(
      HangmanEngine.canApply(s, HintType.revealLetter),
      HangmanEngine.canReveal(s),
    );
    expect(
      HangmanEngine.canApply(s, HintType.removeLetters),
      HangmanEngine.canRemove(s),
    );
    expect(
      HangmanEngine.canApply(s, HintType.extraChance),
      HangmanEngine.canExtraChance(s),
    );
  });

  test('availableLetters excludes guessed and removed', () {
    var s = GameState.initial(_level());
    s = HangmanEngine.guess(s, 'B');
    s = HangmanEngine.removeLetters(s);
    final available = HangmanEngine.availableLetters(s);
    expect(available.contains('B'), isFalse);
    for (final r in s.removedByHint) {
      expect(available.contains(r), isFalse);
    }
  });
}
