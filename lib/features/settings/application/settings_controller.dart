import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../domain/app_settings.dart';

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final settings = ref.watch(settingsRepositoryProvider).load();
    // Sync service toggles with loaded settings on first build.
    _syncServices(settings);
    return settings;
  }

  void _syncServices(AppSettings settings) {
    ref.read(audioServiceProvider).enabled = settings.soundEnabled;
    ref.read(hapticsServiceProvider).enabled = settings.hapticsEnabled;
  }

  Future<void> _update(AppSettings next) async {
    state = next;
    _syncServices(next);
    await ref.read(settingsRepositoryProvider).save(next);
  }

  Future<void> setSound(bool value) =>
      _update(state.copyWith(soundEnabled: value));

  Future<void> setMusic(bool value) =>
      _update(state.copyWith(musicEnabled: value));

  Future<void> setHaptics(bool value) =>
      _update(state.copyWith(hapticsEnabled: value));

  Future<void> completeTutorial() =>
      _update(state.copyWith(tutorialCompleted: true));

  /// Marks the tutorial un-seen so it can be replayed from Settings.
  Future<void> replayTutorial() =>
      _update(state.copyWith(tutorialCompleted: false));

  Future<void> resetToDefaults() async {
    await ref.read(settingsRepositoryProvider).reset();
    await _update(AppSettings.initial());
  }
}
