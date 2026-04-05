// lib/features/game_wordle/presentation/wordle_screen.dart
//
// Kelimelik — Wordle-style word guessing game.
// 5-letter Turkish words, 6 attempts.
// Tile colors: correct (green), misplaced (orange), wrong (gray).

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/game_result.dart';
import '../domain/wordle_game.dart';

class WordleScreen extends ConsumerStatefulWidget {
  const WordleScreen({super.key});

  @override
  ConsumerState<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends ConsumerState<WordleScreen> {
  late WordleGame _game;
  bool _isShaking = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    final words = HiveService.fiveLetterWords;
    final word = words.isEmpty
        ? 'ELMA' // fallback if database not loaded
        : words[DateTime.now().millisecondsSinceEpoch % words.length];
    _game = WordleGame(targetWord: word.toUpperCase());
  }

  void _onKeyTap(String key) {
    if (_game.isFinished) return;
    setState(() {
      if (key == 'DEL') {
        _game.deleteLetter();
      } else if (key == 'ENTER') {
        _submitGuess();
      } else {
        _game.addLetter(key);
      }
    });
  }

  void _submitGuess() {
    final s = S.of(context);
    final result = _game.submitGuess();

    switch (result) {
      case GuessResult.tooShort:
        _showMessage(s.wordleTooShort);
        _shake();
      case GuessResult.invalidWord:
        _showMessage(s.wordleInvalidWord);
        _shake();
      case GuessResult.valid:
        setState(() {});
        if (_game.isFinished) {
          _navigateToReveal();
        }
    }
  }

  void _showMessage(String msg) {
    setState(() => _message = msg);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _message = null);
    });
  }

  void _shake() async {
    setState(() => _isShaking = true);
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _isShaking = false);
  }

  void _navigateToReveal() {
    final result = GameResult(
      mode: GameMode.wordle,
      outcome: _game.won ? GameOutcome.win : GameOutcome.lose,
      score: _game.score,
      word: _game.targetWord,
      attemptsUsed: _game.currentRow,
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        context.push(AppRoutes.tdkReveal, extra: TdkRevealExtra(
          word: _game.targetWord,
          gameResult: result,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: Text(s.wordleTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_game.currentRow}/${AppConfig.wordleMaxAttempts}',
                style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Message toast
            if (_message != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.bgBorder),
                ),
                child: Text(_message!, style: AppTheme.labelLarge),
              ).animate().fadeIn(duration: 200.ms),

            const Spacer(),

            // Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _WordleGrid(
                game: _game,
                isShaking: _isShaking,
              ),
            ),

            const Spacer(),

            // Keyboard
            _TurkishKeyboard(
              keyStates: _game.keyStates,
              onKey: _onKeyTap,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Grid ─────────────────────────────────────────────────────────────────────

class _WordleGrid extends StatelessWidget {
  const _WordleGrid({required this.game, required this.isShaking});
  final WordleGame game;
  final bool isShaking;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(AppConfig.wordleMaxAttempts, (row) {
        final isCurrentRow = row == game.currentRow && !game.isFinished;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          transform: isShaking && isCurrentRow
              ? (Matrix4.identity()..translate(6.0))
              : Matrix4.identity(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(AppConfig.wordleWordLength, (col) {
              final letter = game.getLetter(row, col);
              final state = game.getTileState(row, col);
              return _Tile(letter: letter, state: state, row: row, col: col);
            }),
          ),
        );
      }),
    );
  }
}

enum TileState { empty, filled, correct, misplaced, wrong }

class _Tile extends StatelessWidget {
  const _Tile({
    required this.letter,
    required this.state,
    required this.row,
    required this.col,
  });
  final String letter;
  final TileState state;
  final int row;
  final int col;

  Color get _bg => switch (state) {
    TileState.empty     => AppTheme.empty,
    TileState.filled    => AppTheme.bgSurface,
    TileState.correct   => AppTheme.correct,
    TileState.misplaced => AppTheme.misplaced,
    TileState.wrong     => AppTheme.wrong,
  };

  Color get _border => switch (state) {
    TileState.empty     => AppTheme.bgBorder,
    TileState.filled    => AppTheme.textSecondary,
    _                   => Colors.transparent,
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + col * 100),
      margin: const EdgeInsets.all(3),
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border, width: 2),
      ),
      child: Center(
        child: Text(letter,
          style: AppTheme.gameTile,
          semanticsLabel: letter.isEmpty ? 'empty' : letter,
        ),
      ),
    );
  }
}

// ─── Turkish Keyboard ─────────────────────────────────────────────────────────

class _TurkishKeyboard extends StatelessWidget {
  const _TurkishKeyboard({required this.keyStates, required this.onKey});
  final Map<String, TileState> keyStates;
  final void Function(String) onKey;

  static const _rows = [
    ['E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'Ğ', 'Ü'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Ş', 'İ'],
    ['ENTER', 'Z', 'C', 'V', 'B', 'N', 'M', 'Ö', 'Ç', 'DEL'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _rows.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) => _Key(
            label: key,
            state: keyStates[key] ?? TileState.empty,
            onTap: () => onKey(key),
          )).toList(),
        );
      }).toList(),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.state, required this.onTap});
  final String label;
  final TileState state;
  final VoidCallback onTap;

  Color get _bg => switch (state) {
    TileState.correct   => AppTheme.correct,
    TileState.misplaced => AppTheme.misplaced,
    TileState.wrong     => AppTheme.wrong,
    _                   => AppTheme.bgSurface,
  };

  bool get _isSpecial => label == 'ENTER' || label == 'DEL';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _isSpecial ? 52 : 32,
        height: 44,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            _isSpecial && label == 'DEL' ? '⌫' : label,
            style: TextStyle(
              fontSize: _isSpecial ? 11 : 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
