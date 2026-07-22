import '../../../core/constants/game_config.dart';
import '../../../core/utilities/word_utils.dart';
import 'difficulty.dart';
import 'scene_theme.dart';

/// Default guessable alphabet (English). Localized levels override this with
/// their language's letters, including Nordic/German extras (Ä Ö Ü Å).
const String kDefaultAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

/// An immutable, typed level definition.
class GameLevel {
  const GameLevel({
    required this.id,
    required this.category,
    required this.clue,
    required this.answer,
    required this.difficulty,
    this.alternateAnswers = const [],
    this.maxMistakes = GameConfig.defaultMaxMistakes,
    this.coinReward = 20,
    this.explanation,
    this.explicitScene,
    this.alphabet = kDefaultAlphabet,
  });

  final int id;
  final String category;
  final String clue;

  /// Primary accepted answer (case/spacing-insensitive on compare).
  final String answer;

  /// Additional spellings/synonyms that also count as solved.
  final List<String> alternateAnswers;

  final Difficulty difficulty;
  final int maxMistakes;
  final int coinReward;
  final String? explanation;

  /// Explicit scene override; when null the scene is derived from [id].
  final SceneTheme? explicitScene;

  /// The language's guessable upper-case letters (keyboard + hint pool).
  final String alphabet;

  /// The alphabet as a list of single-character strings.
  List<String> get letters => alphabet.split('');

  /// Scene is explicit when provided, else deterministically derived from id so
  /// the same level always looks the same.
  SceneTheme get scene => explicitScene ?? SceneTheme.forSeed(id);

  /// Normalised primary answer.
  String get normalizedAnswer => WordUtils.normalize(answer);

  /// All acceptable normalised answers.
  List<String> get acceptedAnswers =>
      [answer, ...alternateAnswers].map(WordUtils.normalize).toList();

  /// Letters required to reveal the primary answer.
  Set<String> get requiredLetters => WordUtils.requiredLetters(answer);
}
