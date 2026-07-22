import 'package:doodle_word_quest/core/utilities/word_utils.dart';
import 'package:doodle_word_quest/data/seed_levels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('seed levels validation', () {
    test('has the full 100-level catalogue', () {
      expect(kSeedLevels.length, 100);
    });

    test('ids are unique and sequential from 1', () {
      final ids = kSeedLevels.map((l) => l.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate ids');
      expect(ids.first, 1);
      for (var i = 1; i < ids.length; i++) {
        expect(ids[i], ids[i - 1] + 1, reason: 'ids must be sequential');
      }
    });

    test('clues and answers are non-empty', () {
      for (final l in kSeedLevels) {
        expect(l.clue.trim(), isNotEmpty, reason: 'level ${l.id} clue');
        expect(l.answer.trim(), isNotEmpty, reason: 'level ${l.id} answer');
      }
    });

    test('answers contain guessable letters', () {
      for (final l in kSeedLevels) {
        expect(
          WordUtils.hasGuessableLetter(l.answer),
          isTrue,
          reason: 'level ${l.id}',
        );
      }
    });

    test('rewards are positive and mistakes are valid', () {
      for (final l in kSeedLevels) {
        expect(l.coinReward, greaterThan(0), reason: 'level ${l.id} reward');
        expect(
          l.maxMistakes,
          inInclusiveRange(3, 10),
          reason: 'level ${l.id} maxMistakes',
        );
      }
    });

    test('no duplicated question/answer pairs', () {
      final pairs = kSeedLevels
          .map((l) => '${l.clue.trim().toLowerCase()}::${l.normalizedAnswer}')
          .toList();
      expect(pairs.toSet().length, pairs.length);
    });

    test('answers are unique', () {
      final answers = kSeedLevels.map((l) => l.normalizedAnswer).toList();
      expect(answers.toSet().length, answers.length);
    });

    test('every level has at least one required letter', () {
      for (final l in kSeedLevels) {
        expect(l.requiredLetters, isNotEmpty, reason: 'level ${l.id}');
      }
    });
  });
}
