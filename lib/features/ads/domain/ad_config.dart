import 'package:flutter/foundation.dart';

/// Ad unit identifiers for a single platform.
@immutable
class AdUnitIds {
  const AdUnitIds({
    required this.banner,
    required this.interstitial,
    required this.rewarded,
  });

  final String banner;
  final String interstitial;
  final String rewarded;
}

/// Centralised AdMob configuration.
///
/// ┌──────────────────────────────────────────────────────────────────────────┐
/// │ WHERE TO ENTER YOUR REAL ADMOB IDS (see README → "AdMob setup"):           │
/// │                                                                            │
/// │  • Android App ID  → android/app/src/main/AndroidManifest.xml             │
/// │       <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID"│
/// │                  android:value="ca-app-pub-XXXX~XXXX"/>                    │
/// │  • iOS App ID      → ios/Runner/Info.plist  (key: GADApplicationIdentifier)│
/// │  • Android ad unit IDs → [_prodAndroid] below                             │
/// │  • iOS ad unit IDs     → [_prodIos] below                                 │
/// └──────────────────────────────────────────────────────────────────────────┘
///
/// In debug builds the official Google **test** ad units are always used, so no
/// real inventory is ever requested during development. Automated tests use the
/// no-op ad service and therefore never touch these IDs at all.
abstract final class AdConfig {
  // ===========================================================================
  // App IDs — informational copies of what you must place in the native config.
  // Replace the production values with your own AdMob App IDs.
  // ===========================================================================

  /// Google's sample App ID (safe placeholder). Replace in AndroidManifest.xml.
  static const String androidAppIdTest =
      'ca-app-pub-3940256099942544~3347511713';

  /// Google's sample App ID (safe placeholder). Replace in Info.plist.
  static const String iosAppIdTest = 'ca-app-pub-3940256099942544~1458002511';

  /// Production AdMob App IDs for "Hangman Inky Words" (also placed in the
  /// native AndroidManifest.xml / Info.plist).
  static const String androidAppIdProd =
      'ca-app-pub-7434725459068649~4678136247';
  static const String iosAppIdProd = 'ca-app-pub-7434725459068649~6150879874';

  // ===========================================================================
  // Ad unit IDs.
  // ===========================================================================

  /// Official Google test ad units for Android.
  static const AdUnitIds _testAndroid = AdUnitIds(
    banner: 'ca-app-pub-3940256099942544/6300978111',
    interstitial: 'ca-app-pub-3940256099942544/1033173712',
    rewarded: 'ca-app-pub-3940256099942544/5224354917',
  );

  /// Official Google test ad units for iOS.
  static const AdUnitIds _testIos = AdUnitIds(
    banner: 'ca-app-pub-3940256099942544/2934735716',
    interstitial: 'ca-app-pub-3940256099942544/4411468910',
    rewarded: 'ca-app-pub-3940256099942544/1712485313',
  );

  /// Production Android ad unit IDs for "Hangman Inky Words".
  static const AdUnitIds _prodAndroid = AdUnitIds(
    banner: 'ca-app-pub-7434725459068649/9038831893',
    interstitial: 'ca-app-pub-7434725459068649/2020063179',
    rewarded: 'ca-app-pub-7434725459068649/8525761772',
  );

  /// Production iOS ad unit IDs for "Hangman Inky Words".
  static const AdUnitIds _prodIos = AdUnitIds(
    banner: 'ca-app-pub-7434725459068649/8516087710',
    interstitial: 'ca-app-pub-7434725459068649/1160341876',
    rewarded: 'ca-app-pub-7434725459068649/4203493523',
  );

  /// True whenever Google test ads should be used (any debug build).
  static bool get useTestAds => kDebugMode;

  static bool get _isIos => defaultTargetPlatform == TargetPlatform.iOS;

  static AdUnitIds get _ids {
    if (useTestAds) return _isIos ? _testIos : _testAndroid;
    return _isIos ? _prodIos : _prodAndroid;
  }

  static String get bannerUnitId => _ids.banner;
  static String get interstitialUnitId => _ids.interstitial;
  static String get rewardedUnitId => _ids.rewarded;

  /// Show interstitial after every N completed levels.
  static const int interstitialEveryNLevels = 4;
}
