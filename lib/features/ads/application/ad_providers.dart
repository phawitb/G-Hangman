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
