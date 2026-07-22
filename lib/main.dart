import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/persistence/key_value_store.dart';
import 'core/providers.dart';
import 'features/ads/application/ad_providers.dart';
import 'features/ads/application/ad_service.dart';
import 'features/ads/application/google_ad_service.dart';
import 'features/ads/application/noop_ad_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait-only, matching the app's responsive design.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialise local storage. If it fails, fall back to an in-memory store so
  // the app still runs (progress just won't persist this session).
  KeyValueStore store;
  try {
    store = await SharedPrefsKeyValueStore.create();
  } catch (e) {
    debugPrint('Storage init failed, using in-memory fallback: $e');
    store = InMemoryKeyValueStore();
  }

  // Ads run on Android/iOS only. On web we keep the no-op service so gameplay
  // stays fully functional. Consent + SDK init happen in the background so
  // startup is never blocked by the network.
  final AdService adService = kIsWeb ? NoopAdService() : GoogleAdService();
  unawaited(adService.initialize());

  runApp(
    ProviderScope(
      overrides: [
        keyValueStoreProvider.overrideWithValue(store),
        adServiceProvider.overrideWithValue(adService),
      ],
      child: const DoodleWordQuestApp(),
    ),
  );
}
