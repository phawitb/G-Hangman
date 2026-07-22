import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Logical sound events in the game.
enum SoundEvent { tap, correct, wrong, win, lose, coin, hint, chest }

/// Audio abstraction.
///
/// Version 1 ships without bundled audio files to avoid missing-asset errors,
/// so this uses the platform's built-in [SystemSoundType] where a sensible
/// mapping exists and no-ops otherwise. Swapping in `just_audio`/`audioplayers`
/// later only means providing a different [AudioService] implementation to the
/// provider — no call sites change.
abstract interface class AudioService {
  Future<void> play(SoundEvent event);
  set enabled(bool value);
  bool get enabled;
}

class SystemAudioService implements AudioService {
  SystemAudioService([this._enabled = true]);

  bool _enabled;

  @override
  bool get enabled => _enabled;

  @override
  set enabled(bool value) => _enabled = value;

  @override
  Future<void> play(SoundEvent event) async {
    if (!_enabled) return;
    try {
      // Map events onto the two available system sounds; anything without a
      // good match stays silent rather than referencing a missing asset.
      final sound = switch (event) {
        SoundEvent.tap ||
        SoundEvent.correct ||
        SoundEvent.coin ||
        SoundEvent.hint => SystemSoundType.click,
        SoundEvent.win || SoundEvent.chest => SystemSoundType.alert,
        SoundEvent.wrong || SoundEvent.lose => null,
      };
      if (sound != null) await SystemSound.play(sound);
    } catch (e) {
      // Never let audio crash gameplay.
      debugPrint('AudioService: play($event) failed ($e).');
    }
  }
}

/// A guaranteed-silent implementation, handy for tests.
class NoopAudioService implements AudioService {
  @override
  bool enabled = false;

  @override
  Future<void> play(SoundEvent event) async {}
}
