// lib/features/game_anagram/presentation/anagram_screen.dart
//
// Kelimelik — Anagram game.
// Tap shuffled tiles to arrange them into the correct word.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/game_result.dart';

class AnagramScreen extends ConsumerStatefulWidget {
  const AnagramScreen({super.key});

  @override
  ConsumerState<AnagramScreen> createState() => _AnagramScreenState();
}

class _AnagramScreenState extends ConsumerState<AnagramScreen> with SingleTickerProviderStateMixin {
  late String _targetWord;
  late List<String> _shuffled;
  late List<String?> _answer;
  bool _hintUsed = false;
  bool _solved = false;
  int _score = 0;
  late AnimationController _timerController;
  static const _totalSeconds = 60;

  @override
  void initState() {
    super.initState();
    _initGame();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _totalSeconds),
    )..forward();
    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_solved) {
        _onTimeUp();
      }
    });
  }

  void _initGame() {
    final words = HiveService.getWordsForAnagram();
    final pool = words.isEmpty ? ['KELIME', 'ELMAS', 'ARABA', 'YILDIZ'] : words;
    _targetWord = pool[Random().nextInt(pool.length)].toUpperCase();
    _shuffled = _targetWord.split('')..shuffle();
    _answer = List.filled(_targetWord.length, null);
  }

  void _onShuffledTap(int idx) {
    if (_solved || _shuffled[idx] == '') return;
    final letter = _shuffled[idx];
    final emptySlot = _answer.indexWhere((a) => a == null);
    if (emptySlot == -1) return;

    setState(() {
      _answer[emptySlot] = letter;
      _shuffled[idx] = '';
    });
    HapticFeedback.selectionClick();
    _checkSolved();
  }

  void _onAnswerTap(int idx) {
    if (_solved || _answer[idx] == null) return;
    final letter = _answer[idx]!;

    // Find first empty slot in shuffled
    final emptyIdx = _shuffled.indexWhere((s) => s == '');
    setState(() {
      _answer[idx] = null;
      if (emptyIdx != -1) {
        _shuffled[emptyIdx] = letter;
      } else {
        _shuffled.add(letter);
      }
    });
  }

  void _shuffle() {
    // Return all answer tiles and re-shuffle
    setState(() {
      for (int i = 0; i < _answer.length; i++) {
        if (_answer[i] != null) _shuffled.add(_answer[i]!);
        _answer[i] = null;
      }
      final nonEmpty = _shuffled.where((s) => s.isNotEmpty).toList()..shuffle();
      for (int i = 0; i < _shuffled.length; i++) {
        _shuffled[i] = i < nonEmpty.length ? nonEmpty[i] : '';
      }
    });
  }

  void _useHint() {
    if (_hintUsed || _solved) return;
    // Reveal the first unplaced letter in correct position
    for (int i = 0; i < _targetWord.length; i++) {
      if (_answer[i] == null) {
        final neededLetter = _targetWord[i];
        final shuffledIdx = _shuffled.indexWhere((s) => s == neededLetter);
        if (shuffledIdx != -1) {
          setState(() {
            _answer[i] = neededLetter;
            _shuffled[shuffledIdx] = '';
            _hintUsed = true;
          });
          _checkSolved();
          return;
        }
      }
    }
  }

  void _checkSolved() {
    final attempt = _answer.where((a) => a != null).join();
    if (attempt == _targetWord) {
      HapticFeedback.heavyImpact();
      final elapsed = (_totalSeconds * (1 - _timerController.value)).round();
      setState(() {
        _solved = true;
        _score = 300 + (elapsed * 3) + (_hintUsed ? 0 : 100);
      });
      _timerController.stop();
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) _navigateToReveal(GameOutcome.win);
      });
    }
  }

  void _onTimeUp() {
    setState(() => _solved = true);
    _navigateToReveal(GameOutcome.timeout);
  }

  void _navigateToReveal(GameOutcome outcome) {
    final result = GameResult(
      mode: GameMode.anagram,
      outcome: outcome,
      score: _score,
      word: _targetWord,
      durationSeconds: (_totalSeconds * (1 - _timerController.value)).round(),
    );
    context.push(AppRoutes.tdkReveal, extra: TdkRevealExtra(
      word: _targetWord,
      gameResult: result,
    ));
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: Text(s.anagramTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Timer
              AnimatedBuilder(
                animation: _timerController,
                builder: (_, __) {
                  final remaining = (_totalSeconds * (1 - _timerController.value)).ceil();
                  return Column(
                    children: [
                      Text('$remaining',
                        style: AppTheme.gameTimer.copyWith(
                          color: remaining < 10 ? AppTheme.error : AppTheme.primary)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 1 - _timerController.value,
                        backgroundColor: AppTheme.bgBorder,
                        valueColor: AlwaysStoppedAnimation(
                          remaining < 10 ? AppTheme.error : AppTheme.primary),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),

              // Answer slots
              Wrap(
                spacing: 8,
                children: List.generate(_answer.length, (i) {
                  return GestureDetector(
                    onTap: () => _onAnswerTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44, height: 52,
                      decoration: BoxDecoration(
                        color: _answer[i] != null ? AppTheme.accentPurple.withValues(alpha: 0.2) : AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _answer[i] != null ? AppTheme.accentPurple : AppTheme.bgBorder,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(_answer[i] ?? '', style: AppTheme.gameTile),
                      ),
                    ),
                  );
                }),
              ),

              if (_solved && _answer.join() == _targetWord) ...[
                const SizedBox(height: 24),
                Text(s.anagramSolved,
                  style: AppTheme.headlineLarge.copyWith(color: AppTheme.correct))
                  .animate().fadeIn().scale(),
              ],

              const Spacer(),

              // Shuffled tiles
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(_shuffled.length, (i) {
                  if (_shuffled[i].isEmpty) return const SizedBox(width: 44, height: 52);
                  return GestureDetector(
                    onTap: () => _onShuffledTap(i),
                    child: Container(
                      width: 44, height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.bgBorder, width: 2),
                      ),
                      child: Center(
                        child: Text(_shuffled[i], style: AppTheme.gameTile),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _shuffle,
                      icon: const Icon(Icons.shuffle_rounded, size: 18),
                      label: Text(s.anagramShuffle),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _hintUsed ? null : _useHint,
                      icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
                      label: Text(s.anagramHint),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
