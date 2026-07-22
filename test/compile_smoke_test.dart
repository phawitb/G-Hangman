// Forces the Dart frontend to compile the full app surface (including the
// files not otherwise reached by other tests) so a missing symbol or bad
// signature is caught in CI without needing the native Android/iOS toolchains.
import 'package:doodle_word_quest/app/app.dart';
import 'package:doodle_word_quest/app/router.dart';
import 'package:doodle_word_quest/features/ads/application/google_ad_service.dart';
import 'package:doodle_word_quest/features/ads/presentation/banner_ad_widget.dart';
import 'package:doodle_word_quest/features/daily/presentation/daily_screen.dart';
import 'package:doodle_word_quest/features/gameplay/presentation/game_screen.dart';
import 'package:doodle_word_quest/features/gameplay/presentation/invalid_level_view.dart';
import 'package:doodle_word_quest/features/home/presentation/home_screen.dart';
import 'package:doodle_word_quest/features/level_select/presentation/level_select_screen.dart';
import 'package:doodle_word_quest/features/localization/presentation/language_select_screen.dart';
import 'package:doodle_word_quest/features/results/presentation/result_screen.dart';
import 'package:doodle_word_quest/features/settings/presentation/info_page.dart';
import 'package:doodle_word_quest/features/settings/presentation/settings_screen.dart';
import 'package:doodle_word_quest/features/tutorial/presentation/tutorial_screen.dart';
import 'package:doodle_word_quest/features/two_player/presentation/two_player_game_screen.dart';
import 'package:doodle_word_quest/features/two_player/presentation/two_player_setup_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all top-level libraries compile and expose their entry types', () {
    expect(DoodleWordQuestApp, isNotNull);
    expect(routerProvider, isNotNull);
    expect(const GameScreen(levelId: 1), isNotNull);
    expect(const DailyScreen(), isNotNull);
    expect(const InvalidLevelView(), isNotNull);
    expect(const HomeScreen(), isNotNull);
    expect(const LevelSelectScreen(), isNotNull);
    expect(const LanguageSelectScreen(), isNotNull);
    expect(const SettingsScreen(), isNotNull);
    expect(const TutorialScreen(), isNotNull);
    expect(const TwoPlayerSetupScreen(), isNotNull);
    expect(kPrivacyPlaceholder, isNotEmpty);
    expect(kTermsPlaceholder, isNotEmpty);
    // Reference the remaining screen constructors so their libraries compile.
    expect(ResultScreen, isNotNull);
    expect(TwoPlayerGameScreen, isNotNull);
    // Ads layer (incl. the google_mobile_ads-backed service) compiles.
    expect(GoogleAdService, isNotNull);
    expect(const BannerAdWidget(), isNotNull);
  });
}
