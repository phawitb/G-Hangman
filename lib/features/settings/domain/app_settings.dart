/// Persistent user preferences.
class AppSettings {
  const AppSettings({
    required this.soundEnabled,
    required this.musicEnabled,
    required this.hapticsEnabled,
    required this.tutorialCompleted,
  });

  factory AppSettings.initial() => const AppSettings(
    soundEnabled: true,
    musicEnabled: true,
    hapticsEnabled: true,
    tutorialCompleted: false,
  );

  final bool soundEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool tutorialCompleted;

  AppSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? tutorialCompleted,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'version': 1,
    'soundEnabled': soundEnabled,
    'musicEnabled': musicEnabled,
    'hapticsEnabled': hapticsEnabled,
    'tutorialCompleted': tutorialCompleted,
  };

  static AppSettings fromJson(Map<String, dynamic> json) {
    final base = AppSettings.initial();
    return AppSettings(
      soundEnabled: _bool(json['soundEnabled'], base.soundEnabled),
      musicEnabled: _bool(json['musicEnabled'], base.musicEnabled),
      hapticsEnabled: _bool(json['hapticsEnabled'], base.hapticsEnabled),
      tutorialCompleted: _bool(
        json['tutorialCompleted'],
        base.tutorialCompleted,
      ),
    );
  }

  static bool _bool(Object? v, bool fallback) => v is bool ? v : fallback;
}
