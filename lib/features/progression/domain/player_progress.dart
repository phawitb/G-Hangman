import '../../../core/constants/economy.dart';
import 'level_record.dart';

/// Aggregate persistent progression state for the player.
class PlayerProgress {
  const PlayerProgress({
    required this.coins,
    required this.unlockedLevelId,
    required this.records,
    required this.currentStreak,
    required this.longestStreak,
    required this.perfectCount,
    required this.winsTowardChest,
    required this.chestsOpened,
  });

  factory PlayerProgress.initial() => PlayerProgress(
    coins: Economy.startingCoins,
    unlockedLevelId: 1,
    records: const {},
    currentStreak: 0,
    longestStreak: 0,
    perfectCount: 0,
    winsTowardChest: 0,
    chestsOpened: 0,
  );

  final int coins;

  /// Highest level id the player is allowed to open (levels unlock in order).
  final int unlockedLevelId;

  /// Best result per level id.
  final Map<int, LevelRecord> records;

  final int currentStreak;
  final int longestStreak;
  final int perfectCount;

  /// Wins accumulated toward the next reward chest (0..Economy.winsPerChest).
  final int winsTowardChest;
  final int chestsOpened;

  bool isUnlocked(int levelId) => levelId <= unlockedLevelId;
  LevelRecord? recordFor(int levelId) => records[levelId];
  int starsFor(int levelId) => records[levelId]?.stars ?? 0;
  bool isCompleted(int levelId) => (records[levelId]?.stars ?? 0) > 0;

  int get totalStars => records.values.fold(0, (sum, r) => sum + r.stars);
  int get completedCount => records.values.where((r) => r.isCompleted).length;

  /// True when enough wins have piled up to open a chest.
  bool get chestReady => winsTowardChest >= Economy.winsPerChest;

  PlayerProgress copyWith({
    int? coins,
    int? unlockedLevelId,
    Map<int, LevelRecord>? records,
    int? currentStreak,
    int? longestStreak,
    int? perfectCount,
    int? winsTowardChest,
    int? chestsOpened,
  }) {
    return PlayerProgress(
      coins: coins ?? this.coins,
      unlockedLevelId: unlockedLevelId ?? this.unlockedLevelId,
      records: records ?? this.records,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      perfectCount: perfectCount ?? this.perfectCount,
      winsTowardChest: winsTowardChest ?? this.winsTowardChest,
      chestsOpened: chestsOpened ?? this.chestsOpened,
    );
  }

  Map<String, dynamic> toJson() => {
    'version': 1,
    'coins': coins,
    'unlockedLevelId': unlockedLevelId,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'perfectCount': perfectCount,
    'winsTowardChest': winsTowardChest,
    'chestsOpened': chestsOpened,
    'records': records.values.map((r) => r.toJson()).toList(),
  };

  /// Tolerant parser. Any malformed field degrades to the initial default so a
  /// single bad value cannot erase the whole save.
  static PlayerProgress fromJson(Map<String, dynamic> json) {
    final base = PlayerProgress.initial();
    final recordsList = json['records'];
    final records = <int, LevelRecord>{};
    if (recordsList is List) {
      for (final item in recordsList) {
        if (item is Map<String, dynamic>) {
          final rec = LevelRecord.fromJson(item);
          if (rec != null) records[rec.levelId] = rec;
        }
      }
    }
    return PlayerProgress(
      coins: Economy.clampBalance(_int(json['coins'], base.coins)),
      unlockedLevelId: _int(
        json['unlockedLevelId'],
        base.unlockedLevelId,
      ).clamp(1, 100000),
      records: records,
      currentStreak: _int(json['currentStreak'], 0),
      longestStreak: _int(json['longestStreak'], 0),
      perfectCount: _int(json['perfectCount'], 0),
      winsTowardChest: _int(
        json['winsTowardChest'],
        0,
      ).clamp(0, Economy.winsPerChest),
      chestsOpened: _int(json['chestsOpened'], 0),
    );
  }

  static int _int(Object? v, int fallback) =>
      v is int ? v : (v is num ? v.toInt() : int.tryParse('$v') ?? fallback);
}
