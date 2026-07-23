import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_info.dart';
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
    );
  }
}

/// Removes the Android "stretch" overscroll glow (which looked distorted over
/// the hand-drawn art) in favour of a clean, clamped scroll that simply stops
/// at the edges.
class _NoStretchScrollBehavior extends MaterialScrollBehavior {
  const _NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}
