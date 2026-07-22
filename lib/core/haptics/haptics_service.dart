import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Logical haptic events.
enum HapticEvent { light, selection, success, warning, heavy }

/// Thin wrapper over Flutter's built-in [HapticFeedback] that respects the
/// user's toggle and never throws on unsupported devices.
abstract interface class HapticsService {
  Future<void> trigger(HapticEvent event);
  set enabled(bool value);
  bool get enabled;
}

class PlatformHapticsService implements HapticsService {
  PlatformHapticsService([this._enabled = true]);

  bool _enabled;

  @override
  bool get enabled => _enabled;

  @override
  set enabled(bool value) => _enabled = value;

  @override
  Future<void> trigger(HapticEvent event) async {
    if (!_enabled) return;
    try {
      switch (event) {
        case HapticEvent.light:
          await HapticFeedback.lightImpact();
        case HapticEvent.selection:
          await HapticFeedback.selectionClick();
        case HapticEvent.success:
          await HapticFeedback.mediumImpact();
        case HapticEvent.warning:
          await HapticFeedback.vibrate();
        case HapticEvent.heavy:
          await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      debugPrint('HapticsService: trigger($event) unsupported ($e).');
    }
  }
}

class NoopHapticsService implements HapticsService {
  @override
  bool enabled = false;

  @override
  Future<void> trigger(HapticEvent event) async {}
}
