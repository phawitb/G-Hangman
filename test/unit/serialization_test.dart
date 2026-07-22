import 'package:doodle_word_quest/features/daily/domain/daily_state.dart';
import 'package:doodle_word_quest/features/progression/domain/level_record.dart';
import 'package:doodle_word_quest/features/progression/domain/player_progress.dart';
import 'package:doodle_word_quest/features/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerProgress serialization', () {
    test('round-trips through json', () {
      final progress = PlayerProgress.initial().copyWith(
        coins: 275,
        unlockedLevelId: 5,
        currentStreak: 3,
        longestStreak: 7,
        perfectCount: 2,
        winsTowardChest: 4,
        chestsOpened: 1,
        records: {
          1: const LevelRecord(
            levelId: 1,
            stars: 3,
            bestAccuracy: 1,
            perfect: true,
            timesPlayed: 2,
          ),
        },
      );
      final decoded = PlayerProgress.fromJson(progress.toJson());
      expect(decoded.coins, 275);
      expect(decoded.unlockedLevelId, 5);
      expect(decoded.currentStreak, 3);
      expect(decoded.longestStreak, 7);
      expect(decoded.perfectCount, 2);
      expect(decoded.winsTowardChest, 4);
      expect(decoded.records[1]?.stars, 3);
      expect(decoded.records[1]?.perfect, isTrue);
    });

    test('corrupt fields fall back to defaults', () {
      final decoded = PlayerProgress.fromJson({
        'coins': 'not-a-number',
        'unlockedLevelId': null,
        'records': 'oops',
      });
      expect(decoded.coins, PlayerProgress.initial().coins);
      expect(decoded.unlockedLevelId, 1);
      expect(decoded.records, isEmpty);
    });

    test('negative coins are clamped to zero', () {
      final decoded = PlayerProgress.fromJson({'coins': -50});
      expect(decoded.coins, 0);
    });

    test('bad record entries are skipped, good ones kept', () {
      final decoded = PlayerProgress.fromJson({
        'records': [
          {'levelId': 2, 'stars': 2, 'bestAccuracy': 0.9, 'perfect': false},
          {'no-id': true},
        ],
      });
      expect(decoded.records.length, 1);
      expect(decoded.records[2]?.stars, 2);
    });
  });

  group('AppSettings serialization', () {
    test('round-trips', () {
      const s = AppSettings(
        soundEnabled: false,
        musicEnabled: true,
        hapticsEnabled: false,
        tutorialCompleted: true,
      );
      final decoded = AppSettings.fromJson(s.toJson());
      expect(decoded.soundEnabled, isFalse);
      expect(decoded.tutorialCompleted, isTrue);
    });

    test('missing fields use defaults', () {
      final decoded = AppSettings.fromJson({});
      expect(decoded.soundEnabled, isTrue);
      expect(decoded.tutorialCompleted, isFalse);
    });
  });

  group('DailyState serialization', () {
    test('round-trips completed days', () {
      final s = DailyState.initial().copyWith(
        lastCompletedDay: '2026-01-02',
        currentStreak: 4,
        longestStreak: 9,
        completedDays: {'2026-01-01', '2026-01-02'},
      );
      final decoded = DailyState.fromJson(s.toJson());
      expect(decoded.lastCompletedDay, '2026-01-02');
      expect(decoded.currentStreak, 4);
      expect(decoded.completedDays, containsAll(['2026-01-01', '2026-01-02']));
    });
  });

  test('dayKeyFor formats padded date', () {
    expect(dayKeyFor(DateTime(2026, 3, 5)), '2026-03-05');
  });
}
