import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/localized_levels.dart';
import '../features/gameplay/data/level_repository.dart';
import '../features/localization/application/locale_controller.dart';
import 'audio/audio_service.dart';
import 'haptics/haptics_service.dart';
import 'persistence/daily_repository.dart';
import 'persistence/key_value_store.dart';
import 'persistence/progress_repository.dart';
import 'persistence/settings_repository.dart';

/// Bound to a concrete [KeyValueStore] in `main()` via a provider override.
/// Reading it without an override is a programming error caught early.
final keyValueStoreProvider = Provider<KeyValueStore>((ref) {
  throw StateError(
    'keyValueStoreProvider must be overridden in ProviderScope before use.',
  );
});

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(ref.watch(keyValueStoreProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(keyValueStoreProvider)),
);

final dailyRepositoryProvider = Provider<DailyRepository>(
  (ref) => DailyRepository(ref.watch(keyValueStoreProvider)),
);

/// Language-aware: rebuilds with the current language's level bank.
final levelRepositoryProvider = Provider<LevelRepository>((ref) {
  final lang = ref.watch(localeControllerProvider).language;
  return LevelRepository(LocalizedLevels.forLanguage(lang));
});

final audioServiceProvider = Provider<AudioService>(
  (ref) => SystemAudioService(),
);

final hapticsServiceProvider = Provider<HapticsService>(
  (ref) => PlatformHapticsService(),
);
