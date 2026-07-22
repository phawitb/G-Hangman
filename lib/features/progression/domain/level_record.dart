/// Persistent record of a player's best result on a single level.
class LevelRecord {
  const LevelRecord({
    required this.levelId,
    required this.stars,
    required this.bestAccuracy,
    required this.perfect,
    required this.timesPlayed,
  });

  final int levelId;
  final int stars; // 0–3 (0 means unlocked but not completed)
  final double bestAccuracy; // 0–1
  final bool perfect; // completed with 3 stars at least once
  final int timesPlayed;

  bool get isCompleted => stars > 0;

  LevelRecord copyWith({
    int? stars,
    double? bestAccuracy,
    bool? perfect,
    int? timesPlayed,
  }) {
    return LevelRecord(
      levelId: levelId,
      stars: stars ?? this.stars,
      bestAccuracy: bestAccuracy ?? this.bestAccuracy,
      perfect: perfect ?? this.perfect,
      timesPlayed: timesPlayed ?? this.timesPlayed,
    );
  }

  Map<String, dynamic> toJson() => {
    'levelId': levelId,
    'stars': stars,
    'bestAccuracy': bestAccuracy,
    'perfect': perfect,
    'timesPlayed': timesPlayed,
  };

  /// Tolerant parser: bad or missing fields fall back to safe defaults rather
  /// than throwing, so one corrupt record never wipes all progress.
  static LevelRecord? fromJson(Map<String, dynamic> json) {
    final id = _asInt(json['levelId']);
    if (id == null) return null;
    return LevelRecord(
      levelId: id,
      stars: (_asInt(json['stars']) ?? 0).clamp(0, 3),
      bestAccuracy: (_asDouble(json['bestAccuracy']) ?? 0).clamp(0.0, 1.0),
      perfect: json['perfect'] == true,
      timesPlayed: _asInt(json['timesPlayed']) ?? 0,
    );
  }

  static int? _asInt(Object? v) =>
      v is int ? v : (v is num ? v.toInt() : int.tryParse('$v'));
  static double? _asDouble(Object? v) =>
      v is double ? v : (v is num ? v.toDouble() : double.tryParse('$v'));
}
