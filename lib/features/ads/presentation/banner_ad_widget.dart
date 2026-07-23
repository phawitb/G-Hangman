import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../app/theme/doodle_metrics.dart';
import '../../../core/widgets/doodle_box_painter.dart';
import '../application/ad_providers.dart';
import '../domain/ad_config.dart';

/// A self-contained banner that loads, displays and disposes an anchored
/// standard banner. It occupies **zero** space until an ad actually loads, so
/// it can never overlap buttons, content or the safe area. Place it as a
/// footer inside a [SafeArea]/[Column].
class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _banner;
  bool _loaded = false;
  int _attempts = 0;
  Timer? _retry;

  @override
  void initState() {
    super.initState();
    // Banners are Android/iOS only.
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryLoad());
    }
  }

  void _tryLoad() {
    if (!mounted || _banner != null) return;
    final service = ref.read(adServiceProvider);
    // Consent may still be resolving on first frames — retry a few times.
    if (!service.canRequestAds) {
      if (_attempts++ < 4) {
        _retry = Timer(const Duration(seconds: 2), _tryLoad);
      }
      return;
    }

    final banner = BannerAd(
      size: AdSize.banner,
      adUnitId: AdConfig.bannerUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _banner = ad as BannerAd;
            _loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed to load: ${error.message}');
          ad.dispose();
        },
      ),
    );
    banner.load();
  }

  @override
  void dispose() {
    _retry?.cancel();
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    if (!_loaded || banner == null) {
      // Reserve the bottom safe area so screens (which no longer add their own
      // bottom inset) still stay clear of the gesture bar.
      return const SafeArea(top: false, child: SizedBox.shrink());
    }
    final w = banner.size.width.toDouble();
    final h = banner.size.height.toDouble();
    // Clip the ad to a rounded rect and draw the hand-drawn frame ON TOP, so the
    // ad's own edge chrome (e.g. the dark "Test Ad" bars) is tucked behind the
    // frame and only the clean ad shows inside a doodle border.
    return SafeArea(
      top: false,
      child: Padding(
        // A clear gap above the frame so screen content never crowds the ad.
        padding: const EdgeInsets.fromLTRB(
          DoodleMetrics.sm,
          DoodleMetrics.md,
          DoodleMetrics.sm,
          DoodleMetrics.sm,
        ),
        child: Center(
          child: SizedBox(
            width: w,
            height: h,
            child: CustomPaint(
              foregroundPainter: const DoodleBoxPainter(
                fillColor: Color(0x00000000),
                radius: DoodleMetrics.radiusMd,
                strokeWidth: DoodleMetrics.strokeHeavy,
                seed: 23,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DoodleMetrics.radiusMd),
                child: SizedBox(
                  width: w,
                  height: h,
                  child: AdWidget(ad: banner),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
