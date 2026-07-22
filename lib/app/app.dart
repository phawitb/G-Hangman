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
      routerConfig: router,
    );
  }
}
