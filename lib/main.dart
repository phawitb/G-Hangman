import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/persistence/key_value_store.dart';
import 'core/providers.dart';

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

  runApp(
    ProviderScope(
      overrides: [keyValueStoreProvider.overrideWithValue(store)],
      child: const DoodleWordQuestApp(),
    ),
  );
}
