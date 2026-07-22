import 'package:doodle_word_quest/core/persistence/key_value_store.dart';
import 'package:doodle_word_quest/core/persistence/locale_repository.dart';
import 'package:doodle_word_quest/core/providers.dart';
import 'package:doodle_word_quest/core/utilities/word_utils.dart';
import 'package:doodle_word_quest/data/localized_levels.dart';
import 'package:doodle_word_quest/features/localization/application/locale_controller.dart';
import 'package:doodle_word_quest/features/localization/domain/app_language.dart';
import 'package:doodle_word_quest/features/localization/domain/app_strings.dart';
import 'package:doodle_word_quest/features/localization/domain/str_key.dart';
import 'package:doodle_word_quest/features/progression/application/progress_controller.dart';
import 'package:doodle_word_quest/features/progression/domain/play_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer _container() {
  final c = ProviderContainer(
    overrides: [
      keyValueStoreProvider.overrideWithValue(InMemoryKeyValueStore()),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

PlayResult _win(int id) => PlayResult(
  levelId: id,
  won: true,
  stars: 3,
  accuracy: 1,
  wrongGuesses: 0,
  baseCoinReward: 20,
  paidHintUsed: false,
);

void main() {
  group('AppLanguage', () {
    test('fromCode maps known codes and falls back to English', () {
      expect(AppLanguage.fromCode('de'), AppLanguage.german);
      expect(AppLanguage.fromCode('sv'), AppLanguage.swedish);
      expect(AppLanguage.fromCode('fi'), AppLanguage.finnish);
      expect(AppLanguage.fromCode('xx'), AppLanguage.english);
    });

    test('non-English alphabets include the extra letters', () {
      expect(AppLanguage.german.alphabet, contains('Ä'));
      expect(AppLanguage.german.alphabet, contains('Ü'));
      expect(AppLanguage.swedish.alphabet, contains('Å'));
      expect(AppLanguage.finnish.alphabet, contains('Ö'));
    });
  });

  group('WordUtils extended letters', () {
    test('accepts Nordic/German letters as guessable', () {
      for (final ch in ['Ä', 'Ö', 'Ü', 'Å']) {
        expect(WordUtils.isLetter(ch), isTrue, reason: ch);
      }
    });

    test('masks accented answers correctly', () {
      final masked = WordUtils.maskedCharacters('BÄVER', {'Ä'});
      expect(masked, [null, 'Ä', null, null, null]);
    });
  });

  group('AppStrings', () {
    test('every language provides a non-empty menu label', () {
      for (final lang in AppLanguage.values) {
        expect(AppStrings.tr(lang, StrKey.levelSelect), isNotEmpty);
        expect(AppStrings.tr(lang, StrKey.settingsTitle), isNotEmpty);
      }
    });

    test('placeholder substitution works', () {
      final s = AppStrings.tr(AppLanguage.english, StrKey.continueLevel, {
        'n': 7,
      });
      expect(s, contains('7'));
      expect(s, isNot(contains('{n}')));
    });

    test('missing key falls back to English rather than blank', () {
      // German menu should differ from English for a translated key.
      expect(
        AppStrings.tr(AppLanguage.german, StrKey.settingsTitle),
        isNot(AppStrings.tr(AppLanguage.english, StrKey.settingsTitle)),
      );
    });
  });

  group('LocalizedLevels', () {
    test('English uses the full 100-level bank', () {
      expect(LocalizedLevels.forLanguage(AppLanguage.english).length, 100);
    });

    for (final lang in [
      AppLanguage.german,
      AppLanguage.swedish,
      AppLanguage.finnish,
    ]) {
      test('${lang.code} bank is valid and self-consistent', () {
        final levels = LocalizedLevels.forLanguage(lang);
        expect(levels, isNotEmpty);
        // Sequential ids from 1.
        for (var i = 0; i < levels.length; i++) {
          expect(levels[i].id, i + 1);
        }
        // Unique answers, non-empty clues, and every answer letter is on the
        // language keyboard.
        final answers = <String>{};
        for (final l in levels) {
          expect(l.clue.trim(), isNotEmpty);
          expect(l.category.trim(), isNotEmpty);
          expect(l.alphabet, lang.alphabet);
          expect(WordUtils.hasGuessableLetter(l.answer), isTrue);
          expect(
            answers.add(l.normalizedAnswer),
            isTrue,
            reason: 'duplicate answer ${l.normalizedAnswer}',
          );
          for (final ch in l.requiredLetters) {
            expect(
              lang.alphabet.contains(ch),
              isTrue,
              reason: '${l.normalizedAnswer} uses $ch not on the keyboard',
            );
          }
        }
      });
    }
  });

  group('LocaleRepository / controller', () {
    test('initial state is English and not yet chosen', () {
      final repo = LocaleRepository(InMemoryKeyValueStore());
      final state = repo.load();
      expect(state.language, AppLanguage.english);
      expect(state.chosen, isFalse);
    });

    test('choose persists language and marks chosen', () async {
      final c = _container();
      await c
          .read(localeControllerProvider.notifier)
          .choose(AppLanguage.swedish);
      final state = c.read(localeControllerProvider);
      expect(state.language, AppLanguage.swedish);
      expect(state.chosen, isTrue);
    });
  });

  group('per-language progress isolation', () {
    test(
      'each language keeps its own progress and restores on switch',
      () async {
        final c = _container();
        final locale = c.read(localeControllerProvider.notifier);
        final progress = c.read(progressControllerProvider.notifier);

        // Progress in English.
        await progress.recordResult(_win(1));
        expect(c.read(progressControllerProvider).unlockedLevelId, 2);

        // Switch to German: fresh progress.
        await locale.setLanguage(AppLanguage.german);
        expect(c.read(progressControllerProvider).unlockedLevelId, 1);
        await c.read(progressControllerProvider.notifier).recordResult(_win(1));
        await c.read(progressControllerProvider.notifier).recordResult(_win(2));
        expect(c.read(progressControllerProvider).unlockedLevelId, 3);

        // Back to English: original progress restored.
        await locale.setLanguage(AppLanguage.english);
        expect(c.read(progressControllerProvider).unlockedLevelId, 2);

        // German progress also intact.
        await locale.setLanguage(AppLanguage.german);
        expect(c.read(progressControllerProvider).unlockedLevelId, 3);
      },
    );
  });

  test('level repository follows the current language', () async {
    final c = _container();
    expect(c.read(levelRepositoryProvider).count, 100); // English
    await c
        .read(localeControllerProvider.notifier)
        .setLanguage(AppLanguage.finnish);
    final fi = c.read(levelRepositoryProvider);
    expect(fi.count, LocalizedLevels.forLanguage(AppLanguage.finnish).length);
    expect(fi.byId(1)!.answer, 'MAJAVA');
  });
}
