/// Persistent state for the once-per-day challenge.
class DailyState {
  const DailyState({
    required this.lastCompletedDay,
    required this.currentStreak,
    required this.longestStreak,
    required this.completedDays,
  });

  factory DailyState.initial() => const DailyState(
    lastCompletedDay: null,
    currentStreak: 0,
    longestStreak: 0,
    completedDays: <String>{},
  );

  /// Day key (yyyy-mm-dd) of the most recent completion, or null.
  final String? lastCompletedDay;
  final int currentStreak;
  final int longestStreak;

  /// All completed day keys (used to grey out finished days / prevent re-award).
  final Set<String> completedDays;

  bool isCompleted(String dayKey) => completedDays.contains(dayKey);

  DailyState copyWith({
    String? lastCompletedDay,
    int? currentStreak,
    int? longestStreak,
    Set<String>? completedDays,
  }) {
    return DailyState(
      lastCompletedDay: lastCompletedDay ?? this.lastCompletedDay,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      completedDays: completedDays ?? this.completedDays,
    );
  }

  Map<String, dynamic> toJson() => {
    'version': 1,
    'lastCompletedDay': lastCompletedDay,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'completedDays': completedDays.toList(),
  };

  static DailyState fromJson(Map<String, dynamic> json) {
    final days = <String>{};
    final list = json['completedDays'];
    if (list is List) {
      for (final d in list) {
        if (d is String) days.add(d);
      }
    }
    return DailyState(
      lastCompletedDay: json['lastCompletedDay'] is String
          ? json['lastCompletedDay'] as String
          : null,
      currentStreak: _int(json['currentStreak']),
      longestStreak: _int(json['longestStreak']),
      completedDays: days,
    );
  }

  static int _int(Object? v) =>
      v is int ? v : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);
}

/// Utility for turning a [DateTime] into a stable day key.
String dayKeyFor(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
