import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../domain/daily_state.dart';

final dailyControllerProvider = NotifierProvider<DailyController, DailyState>(
  DailyController.new,
);

class DailyController extends Notifier<DailyState> {
  @override
  DailyState build() => ref.watch(dailyRepositoryProvider).load();

  Future<void> _persist(DailyState next) async {
    state = next;
    await ref.read(dailyRepositoryProvider).save(next);
  }

  /// Records a successful completion of [now]'s challenge.
  ///
  /// Returns true when this is the first completion for that calendar day
  /// (so the caller should award coins exactly once). Streak increases when the
  /// previous completion was the day before; otherwise it restarts at 1.
  Future<bool> completeToday(DateTime now) async {
    final today = dayKeyFor(now);
    if (state.isCompleted(today)) return false;

    final yesterday = dayKeyFor(now.subtract(const Duration(days: 1)));
    final continues = state.lastCompletedDay == yesterday;
    final newStreak = continues ? state.currentStreak + 1 : 1;

    await _persist(
      state.copyWith(
        lastCompletedDay: today,
        currentStreak: newStreak,
        longestStreak: max(state.longestStreak, newStreak),
        completedDays: {...state.completedDays, today},
      ),
    );
    return true;
  }

  bool isCompletedOn(DateTime date) => state.isCompleted(dayKeyFor(date));

  Future<void> resetAll() async {
    await ref.read(dailyRepositoryProvider).reset();
    await _persist(DailyState.initial());
  }
}
