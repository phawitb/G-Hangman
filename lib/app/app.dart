import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_info.dart';
import '../core/widgets/notebook_background.dart';
import '../features/ads/presentation/banner_ad_widget.dart';
import 'router.dart';
import 'theme/app_theme.dart';

/// Root application widget.
class DoodleWordQuestApp extends ConsumerWidget {
  const DoodleWordQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      scrollBehavior: const _NoStretchScrollBehavior(),
      routerConfig: router,
      // A single anchored banner shared by every screen. It occupies no space
      // until an ad loads. The notebook background is painted behind the whole
      // window (same grid origin as each screen), so the paper + grid runs
      // continuously through the banner strip — only the ad carries a frame.
      builder: (context, child) {
        return NotebookBackground(
          child: Column(
            children: [
              // Screens no longer reserve the bottom safe area themselves — the
              // banner footer owns the bottom, so content sits directly above
              // the ad frame with no phantom gesture-inset gap.
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeBottom: true,
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
              const BannerAdWidget(),
            ],
          ),
        );
      },
    );
  }
}

/// Removes the Android "stretch" overscroll glow (which looked distorted over
/// the hand-drawn art) in favour of a clean, clamped scroll that simply stops
/// at the edges.
class _NoStretchScrollBehavior extends MaterialScrollBehavior {
  const _NoStretchScrollBehavior();

  // Allow dragging to scroll with a mouse/trackpad too (not just touch). Without
  // this, click-dragging on the iOS Simulator (a mouse pointer) doesn't scroll.
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.unknown,
  };

  // Remove only the overscroll glow/stretch visual; keep each platform's native
  // scroll physics (iOS bounce, Android clamp) so scrolling always works.
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}
