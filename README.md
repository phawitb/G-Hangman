# Doodle Word Quest

A hand-drawn, notebook-style word-guessing game for **Android** and **iOS**,
built with Flutter. Read a clue, guess the hidden word one letter at a time, and
keep the doodle mascot **Sketch** out of a series of light-hearted predicaments.

> All artwork, characters, icons, animations, questions and UI are **original**
> and drawn from scratch in code (`CustomPainter`). The project was inspired only
> by the broad "warm paper + black ink + yellow highlight" visual language, not
> copied from any existing product. See [`DESIGN_ANALYSIS.md`](DESIGN_ANALYSIS.md).

---

## Screenshots

_Add screenshots here once you run the app (e.g. `docs/home.png`, `docs/game.png`)._

| Home | Gameplay | Result |
| --- | --- | --- |
| _(placeholder)_ | _(placeholder)_ | _(placeholder)_ |

---

## Features

- **Adventure mode** — 100 original levels across 10 categories, unlocking in
  sequence with a rising difficulty curve, plus coins, stars and a reward chest.
- **Two-Player mode** — Player 1 sets a secret word + optional clue and a
  mistake limit; Player 2 guesses. Fully offline.
- **Daily Challenge** — one deterministic level per calendar day with its own
  streak, no server required.
- **Coins, hints & economy** — Reveal a Letter, Remove 3 Letters and Extra
  Chance, all priced from a single config file.
- **Progression** — unlocked levels, stars (3/2/1 rules), best accuracy,
  perfects, coins, current/longest streaks and daily history, all persisted.
- **Hand-drawn design system** — notebook background, wobble-outlined buttons,
  cards and speech bubbles, an original icon set, and three multi-stage danger
  scenes (Balloon Drift, Stepping Stones, Book Stack).
- **Tutorial** — a skippable, replayable first-launch walkthrough using the real
  gameplay components.
- **Accessibility** — semantic labels on icons/keys, 48px minimum tap targets,
  reduced-motion support, and scalable text without overflow.
- **Responsive** — portrait-first, usable from ~320px wide up to tablets.
- **Monetization** — AdMob rewarded, interstitial and banner ads with UMP
  consent, all optional and non-intrusive (see _AdMob monetization_ below).

---

## Tech stack

| Concern | Choice |
| --- | --- |
| Framework | Flutter (stable), Dart null-safety |
| State management | `flutter_riverpod` (Notifier / Provider) |
| Navigation | `go_router` |
| Persistence | `shared_preferences` (JSON, versioned, corruption-tolerant) |
| Typography | `google_fonts` (Kalam + Patrick Hand, OFL) with graceful fallback |
| Ads | `google_mobile_ads` (rewarded / interstitial / banner + UMP consent) |
| Animation | `flutter_animate` + `AnimationController` / `CustomPainter` |
| Audio | Built-in `SystemSound` abstraction (no-op-safe, no bundled files) |
| Haptics | Built-in `HapticFeedback` abstraction (respects the settings toggle) |
| Art | 100% `CustomPainter` — no image/SVG assets to go missing |

Dependencies are injected through Riverpod providers (`lib/core/providers.dart`).

---

## Architecture

Feature-first, with a clear separation of domain logic, data, application
(controllers) and presentation. The pure game logic (`HangmanEngine`,
`GameState`) has **no** dependency on Flutter, coins, storage or the UI, which is
what makes it exhaustively unit-testable.

```
lib/
  app/            # MaterialApp, GoRouter, theme tokens, routes
    theme/        # doodle_colors, doodle_text_styles, doodle_metrics, app_theme
  core/
    constants/    # economy, game_config, app_info
    persistence/  # KeyValueStore + progress/settings/daily repositories
    audio/        # AudioService abstraction (+ no-op)
    haptics/      # HapticsService abstraction (+ no-op)
    utilities/    # WordUtils (normalisation, masking)
    widgets/      # NotebookBackground, DoodleButton, LetterTile, CharacterScene…
    providers.dart
  data/
    seed_levels.dart   # 100 original levels
  features/
    gameplay/     # domain (engine/state/level), application (controller), presentation
    progression/  # player progress, level records, progress controller
    home/ level_select/ results/ settings/ tutorial/ daily/ two_player/
test/
  unit/           # logic, serialization, seed-data validation, controllers
  widget/         # home + gameplay rendering and interaction
  compile_smoke_test.dart
```

---

## Requirements

- Flutter **stable ≥ 3.44** (developed on 3.44.6 / Dart 3.12).
- Android SDK (for Android builds) and/or macOS + Xcode (for iOS builds).

Check your setup with `flutter doctor`.

---

## Setup & run

```bash
flutter pub get
flutter run
```

The first run fetches the Google Fonts over the network **in debug builds** and
caches them. See _Fonts in release builds_ under Known limitations.

## Quality checks

```bash
dart format .
flutter analyze     # expected: No issues found!
flutter test        # expected: All tests passed! (61 tests)
```

## Build

```bash
# Android (Play Store)
flutter build appbundle

# Android (APK)
flutter build apk --release

# iOS (requires macOS, Xcode, signing, and an Apple Developer account)
flutter build ipa
```

---

## Asset replacement guide

There are **no bundled image assets** — every visual is painted in code, so
nothing can 404 at runtime. To restyle:

- **Colours** — edit `lib/app/theme/doodle_colors.dart`.
- **Type scale** — edit `lib/app/theme/doodle_text_styles.dart`.
- **Spacing / stroke / radii / motion** — edit `lib/app/theme/doodle_metrics.dart`.
- **Icons** — extend `DoodleIconType` and add a draw method in
  `lib/core/widgets/doodle_icons.dart`.
- **Danger scenes** — add a value to `SceneTheme` and a `_paint…` branch in
  `lib/core/widgets/character_scene.dart`.
- **Audio** — provide a real `AudioService` implementation (e.g. with
  `just_audio`) and swap it in `audioServiceProvider`; no call sites change.

## Level-authoring guide

Levels live in `lib/data/seed_levels.dart` as `GameLevel` objects:

```dart
GameLevel(
  id: 101,                      // unique, sequential from 1
  category: 'Animals',
  clue: 'Which bird cannot fly but swims well?',
  answer: 'PENGUIN',            // compared case/space/punctuation-insensitively
  alternateAnswers: [],         // extra accepted spellings
  difficulty: Difficulty.easy,  // easy / medium / hard
  maxMistakes: 7,               // 3–10
  coinReward: 20,               // must be > 0
  explanation: 'Penguins are flightless birds.',
);
```

`test/unit/seed_levels_test.dart` enforces: unique ids, sequential from 1,
non-empty clue/answer, positive rewards, valid mistake range, at least one
guessable letter, and no duplicate answers or question/answer pairs. Run
`flutter test` after editing.

Star rules and hint costs are configurable in
`lib/core/constants/game_config.dart` and `lib/core/constants/economy.dart`.

---

## Changing the package name & bundle ID

Current placeholders:

- Android `applicationId`: `com.example.doodle_word_quest`
  (`android/app/build.gradle.kts`)
- iOS `PRODUCT_BUNDLE_IDENTIFIER`: `com.example.doodleWordQuest`
  (`ios/Runner.xcodeproj` build settings)

The simplest path is the community tool:

```bash
dart pub global activate rename
rename setBundleId --targets android,ios --value com.yourcompany.doodlewordquest
```

Or change them manually in `android/app/build.gradle.kts` (and the Kotlin
package folder under `android/app/src/main/kotlin/…`) and in Xcode
(_Runner → Signing & Capabilities → Bundle Identifier_). Display names are
already set to **Doodle Word Quest** in `AndroidManifest.xml`
(`android:label`) and `Info.plist` (`CFBundleDisplayName`).

---

## AdMob monetization

Ads use the official **`google_mobile_ads`** plugin with Google **UMP** consent.
In debug builds the official Google **test** ad units are always used, and
automated tests use a no-op ad service, so real ad IDs are never touched during
development or CI. Ads are Android/iOS only; the web build uses the no-op service.

**Placements** (intentionally non-intrusive):

| Ad type | Where | Reward / trigger |
| --- | --- | --- |
| Rewarded | Home ("Free 50 coins"), in-game ("Reveal a letter — watch ad"), and after a loss ("keep playing") | Coins / a revealed letter / +2 revive chances — granted **only** inside `onUserEarnedReward` |
| Interstitial | Between levels, from the result screen | Only after every **4th** completed level; never during gameplay; never right after a rewarded ad |
| Banner | Level-select screen footer only | Occupies zero space until loaded, so it never overlaps content |

Watching an ad is **never required** to continue ordinary gameplay, and opening
an ad never grants a reward on its own.

### Where to enter your AdMob IDs

1. **Android App ID** — `android/app/src/main/AndroidManifest.xml`
   (`<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" …>`).
2. **iOS App ID** — `ios/Runner/Info.plist` (key `GADApplicationIdentifier`).
3. **Android ad unit IDs** — `AdConfig._prodAndroid` in
   `lib/features/ads/domain/ad_config.dart`.
4. **iOS ad unit IDs** — `AdConfig._prodIos` in the same file.

All four currently hold Google's sample/test values or clearly-marked
`0000…` placeholders. Replace them with your production IDs before release; the
`AdConfig.useTestAds` switch automatically keeps test units in debug builds.

Consent: `ConsentManager` requests consent info on every launch, shows the form
when required, and gates ad loading on `canRequestAds`. When UMP marks privacy
options as required, a **Privacy Choices** button appears in Settings.

---

## Release checklist

- [ ] Replace the package name / bundle ID placeholders.
- [ ] Replace the AdMob App IDs (manifest + plist) and production ad unit IDs
      (`lib/features/ads/domain/ad_config.dart`); test your fill rate.
- [ ] Replace launcher icons (`flutter_launcher_icons` or platform tooling).
- [ ] Replace the Privacy Policy and Terms placeholders
      (`lib/features/settings/presentation/info_page.dart`).
- [ ] Decide on fonts for release (bundle OFL fonts or accept system fallback).
- [ ] Bump `version:` in `pubspec.yaml` and `AppInfo.version`.
- [ ] `dart format . && flutter analyze && flutter test` all clean.
- [ ] Configure signing (Android keystore, iOS provisioning).
- [ ] Test on a small (~320px) device and at large system text scale.

---

## Known limitations

- **Fonts in release builds.** `google_fonts` fetches over the network in debug
  and caches. Version 1 deliberately requests **no internet permission**, so a
  release install without a cached font falls back to the platform font. To ship
  the handwritten look offline, download the OFL **Kalam** and **Patrick Hand**
  `.ttf` files, add them under `assets/fonts/`, declare them in `pubspec.yaml`,
  and reference them by family in `doodle_text_styles.dart` (drop `google_fonts`).
- **Audio.** Ships with a `SystemSound`-based abstraction and no bundled audio
  files (nothing to go missing). Swap in a real audio service for richer SFX.
- **Two-Player** is local pass-and-play only (no online multiplayer).
- **Localization** is English-only; strings are structured so a second locale
  (e.g. Thai) can be layered on later.

---

## Intellectual-property note

Doodle Word Quest is an original work. Its name, mascot, icons, illustrations,
danger scenes, UI composition, animations, question bank and progression system
were all created for this project. The reference screenshots provided during
development were used solely to inform a **broad visual language** (hand-drawn
notebook feel) and were never traced, cropped, imported, or shipped as assets.
Any final assets you add before release must likewise be original or properly
licensed. The bundled font families (Kalam, Patrick Hand) are used under the
SIL Open Font License.
