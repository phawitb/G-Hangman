import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ad_service.dart';
import 'noop_ad_service.dart';

/// The app-wide [AdService].
///
/// Defaults to [NoopAdService] (used on web and in automated tests, so real ad
/// IDs are never touched). On Android/iOS, `main()` overrides this with a
/// `GoogleAdService` instance.
final adServiceProvider = Provider<AdService>((ref) {
  final service = NoopAdService();
  ref.onDispose(service.dispose);
  return service;
});

/// Reactive mirror of `AdService.canRequestAds`.
///
/// `canRequestAds` is a plain getter that flips to `true` asynchronously once
/// the SDK + consent finish initialising — watching the service instance alone
/// never rebuilds. `main()` (and the privacy-options flow) push the resolved
/// value here so ad-gated widgets (free-coins button, hint "watch ad") appear
/// as soon as ads are actually available.
final adReadyProvider = NotifierProvider<AdReadyNotifier, bool>(
  AdReadyNotifier.new,
);

class AdReadyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}
