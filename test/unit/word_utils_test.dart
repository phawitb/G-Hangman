import 'package:doodle_word_quest/core/utilities/word_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WordUtils.normalize', () {
    test('upper-cases and trims', () {
      expect(WordUtils.normalize('  beaver '), 'BEAVER');
    });
  });

  group('WordUtils.requiredLetters', () {
    test('returns distinct letters, ignoring separators', () {
      expect(WordUtils.requiredLetters('ICE CREAM'), {
        'I',
        'C',
        'E',
        'R',
        'A',
        'M',
      });
    });

    test('handles hyphen and punctuation', () {
      expect(WordUtils.requiredLetters("T-REX!"), {'T', 'R', 'E', 'X'});
    });
  });

  group('WordUtils.isSolved', () {
    test('true when all letters guessed (case-insensitive)', () {
      expect(WordUtils.isSolved('CAT', {'c', 'a', 't'}), isTrue);
    });

    test('false when a letter is missing', () {
      expect(WordUtils.isSolved('CAT', {'C', 'A'}), isFalse);
    });

    test('spaces do not need guessing', () {
      expect(WordUtils.isSolved('A B', {'A', 'B'}), isTrue);
    });
  });

  group('WordUtils.maskedCharacters', () {
    test('reveals guessed letters and keeps separators', () {
      final masked = WordUtils.maskedCharacters('AB C', {'A'});
      expect(masked, ['A', null, ' ', null]);
    });

    test('repeated letters all reveal', () {
      final masked = WordUtils.maskedCharacters('BOOK', {'O'});
      expect(masked, [null, 'O', 'O', null]);
    });
  });

  test('hasGuessableLetter', () {
    expect(WordUtils.hasGuessableLetter('!!'), isFalse);
    expect(WordUtils.hasGuessableLetter('A!'), isTrue);
  });
}
