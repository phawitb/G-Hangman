import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
    if (!_loaded || banner == null) return const SizedBox.shrink();
    return SizedBox(
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      child: AdWidget(ad: banner),
    );
  }
}
