// lib/features/game_wordle/domain/wordle_game.dart
//
// Kelimelik — Wordle game logic.
// Manages grid state, key colors, win/lose detection.

import '../../../core/config/app_config.dart';
import '../../../core/services/hive_service.dart';
import '../../game_wordle/presentation/wordle_screen.dart' show TileState;

enum GuessResult { valid, tooShort, invalidWord }

class WordleGame {
  WordleGame({required this.targetWord}) {
    _grid = List.generate(
      AppConfig.wordleMaxAttempts,
      (_) => List.filled(AppConfig.wordleWordLength, ''),
    );
    _states = List.generate(
      AppConfig.wordleMaxAttempts,
      (_) => List.filled(AppConfig.wordleWordLength, TileState.empty),
    );
  }

  final String targetWord; // must be uppercase, 5 letters
  late final List<List<String>> _grid;
  late final List<List<TileState>> _states;
  final Map<String, TileState> keyStates = {};

  int currentRow = 0;
  int currentCol = 0;
  bool won = false;
  bool lost = false;

  bool get isFinished => won || lost;

  int get score {
    if (!won) return 0;
    // Score based on attempts: 6 attempts = 100, 1 attempt = 600
    return (AppConfig.wordleMaxAttempts - currentRow + 1) * 100;
  }

  String getLetter(int row, int col) => _grid[row][col];
  TileState getTileState(int row, int col) => _states[row][col];

  void addLetter(String letter) {
    if (isFinished || currentCol >= AppConfig.wordleWordLength) return;
    _grid[currentRow][currentCol] = letter.toUpperCase();
    _states[currentRow][currentCol] = TileState.filled;
    currentCol++;
  }

  void deleteLetter() {
    if (isFinished || currentCol <= 0) return;
    currentCol--;
    _grid[currentRow][currentCol] = '';
    _states[currentRow][currentCol] = TileState.empty;
  }

  GuessResult submitGuess() {
    final guess = _grid[currentRow].join();

    if (guess.length < AppConfig.wordleWordLength) {
      return GuessResult.tooShort;
    }

    if (!HiveService.isValid5LetterWord(guess)) {
      return GuessResult.invalidWord;
    }

    _evaluateGuess(guess);
    return GuessResult.valid;
  }

  void _evaluateGuess(String guess) {
    final target = targetWord.toUpperCase();
    final guessChars = guess.split('');
    final targetChars = target.split('');

    final result = List.filled(AppConfig.wordleWordLength, TileState.wrong);
    final targetUsed = List.filled(AppConfig.wordleWordLength, false);
    final guessUsed = List.filled(AppConfig.wordleWordLength, false);

    // First pass: correct positions
    for (int i = 0; i < AppConfig.wordleWordLength; i++) {
      if (guessChars[i] == targetChars[i]) {
        result[i] = TileState.correct;
        targetUsed[i] = true;
        guessUsed[i] = true;
      }
    }

    // Second pass: misplaced
    for (int i = 0; i < AppConfig.wordleWordLength; i++) {
      if (guessUsed[i]) continue;
      for (int j = 0; j < AppConfig.wordleWordLength; j++) {
        if (!targetUsed[j] && guessChars[i] == targetChars[j]) {
          result[i] = TileState.misplaced;
          targetUsed[j] = true;
          break;
        }
      }
    }

    // Apply to grid
    for (int i = 0; i < AppConfig.wordleWordLength; i++) {
      _states[currentRow][i] = result[i];
    }

    // Update keyboard colors (don't downgrade correct → misplaced)
    for (int i = 0; i < AppConfig.wordleWordLength; i++) {
      final key = guessChars[i];
      final current = keyStates[key] ?? TileState.empty;
      if (result[i] == TileState.correct ||
          (result[i] == TileState.misplaced && current != TileState.correct) ||
          (result[i] == TileState.wrong && current == TileState.empty)) {
        keyStates[key] = result[i];
      }
    }

    // Check win/lose
    if (result.every((s) => s == TileState.correct)) {
      won = true;
    }

    currentRow++;
    currentCol = 0;

    if (currentRow >= AppConfig.wordleMaxAttempts && !won) {
      lost = true;
    }
  }
}
