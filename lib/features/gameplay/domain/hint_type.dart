import '../../../core/constants/economy.dart';

/// The three purchasable hints.
enum HintType {
  revealLetter,
  removeLetters,
  extraChance;

  int get cost => switch (this) {
    HintType.revealLetter => Economy.revealLetterCost,
    HintType.removeLetters => Economy.removeLettersCost,
    HintType.extraChance => Economy.extraChanceCost,
  };

  String get label => switch (this) {
    HintType.revealLetter => 'Reveal a letter',
    HintType.removeLetters => 'Remove 3 letters',
    HintType.extraChance => 'Extra chance',
  };

  String get shortLabel => switch (this) {
    HintType.revealLetter => 'Reveal',
    HintType.removeLetters => 'Clear 3',
    HintType.extraChance => '+1 Life',
  };
}

/// Result of attempting to apply a hint, so the UI can give precise feedback.
enum HintOutcome { applied, notEnoughCoins, nothingToDo, alreadyUsedMax }
