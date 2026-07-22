import 'package:doodle_word_quest/features/ads/domain/interstitial_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InterstitialScheduler cadence (every 4)', () {
    test('shows only on the 4th, 8th, 12th completed level', () {
      final s = InterstitialScheduler(everyN: 4);
      final shown = <int>[];
      for (var level = 1; level <= 12; level++) {
        s.registerLevelCompleted();
        if (s.consumeShouldShow()) shown.add(level);
      }
      expect(shown, [4, 8, 12]);
    });

    test('never shows before any level is completed', () {
      final s = InterstitialScheduler(everyN: 4);
      expect(s.consumeShouldShow(), isFalse);
    });

    test('does not show on non-multiples', () {
      final s = InterstitialScheduler(everyN: 4);
      for (var i = 0; i < 3; i++) {
        s.registerLevelCompleted();
        expect(s.consumeShouldShow(), isFalse);
      }
    });
  });

  group('rewarded-ad suppression', () {
    test('a rewarded ad skips the very next interstitial opportunity', () {
      final s = InterstitialScheduler(everyN: 4);
      for (var i = 0; i < 4; i++) {
        s.registerLevelCompleted();
      }
      // A rewarded ad was just shown before this 4th-level break.
      s.suppressNext();
      expect(s.consumeShouldShow(), isFalse, reason: 'suppressed by rewarded');

      // Suppression is one-shot; the next multiple shows again.
      for (var i = 0; i < 4; i++) {
        s.registerLevelCompleted();
      }
      expect(s.consumeShouldShow(), isTrue);
    });

    test('suppression clears even on a non-showing check', () {
      final s = InterstitialScheduler(everyN: 4);
      s.registerLevelCompleted(); // count = 1
      s.suppressNext();
      expect(s.consumeShouldShow(), isFalse); // clears suppression
      expect(s.isSuppressed, isFalse);
    });
  });

  test('reset clears counters and suppression', () {
    final s = InterstitialScheduler(everyN: 4);
    for (var i = 0; i < 4; i++) {
      s.registerLevelCompleted();
    }
    s.suppressNext();
    s.reset();
    expect(s.completedLevels, 0);
    expect(s.isSuppressed, isFalse);
    expect(s.consumeShouldShow(), isFalse);
  });
}
