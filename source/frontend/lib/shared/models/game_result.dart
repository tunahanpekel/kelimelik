// lib/shared/models/game_result.dart
//
// Kelimelik — shared game result model used across all game modes.

enum GameMode { wordle, chain, anagram, speed, category }

enum GameOutcome { win, lose, timeout }

class GameResult {
  const GameResult({
    required this.mode,
    required this.outcome,
    required this.score,
    required this.word,
    this.attemptsUsed,
    this.durationSeconds,
    this.wordsCount,
    this.chainLength,
  });

  final GameMode mode;
  final GameOutcome outcome;
  final int score;
  final String word;        // The main word of the round (for TDK reveal)
  final int? attemptsUsed;  // Wordle only
  final int? durationSeconds;
  final int? wordsCount;    // Speed / Category
  final int? chainLength;   // Chain mode

  bool get isWin => outcome == GameOutcome.win;

  String get modeId => mode.name;
}

// ─── Router extras ────────────────────────────────────────────────────────────

class TdkRevealExtra {
  const TdkRevealExtra({
    required this.word,
    this.gameResult,
  });

  final String word;
  final GameResult? gameResult;
}

class ResultExtra {
  const ResultExtra({
    required this.mode,
    required this.score,
    this.gameResult,
  });

  final String mode;
  final int score;
  final GameResult? gameResult;
}
