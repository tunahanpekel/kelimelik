// lib/features/game_speed/presentation/speed_screen.dart
//
// Kelimelik — Hızlı Tur (Speed Round).
// Type valid Turkish words in 60 seconds.
// Score: valid_words × avg_length × combo_multiplier

import 'dart:async';
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

enum SpeedPhase { countdown, playing, finished }

class SpeedScreen extends ConsumerStatefulWidget {
  const SpeedScreen({super.key});

  @override
  ConsumerState<SpeedScreen> createState() => _SpeedScreenState();
}

class _SpeedScreenState extends ConsumerState<SpeedScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  SpeedPhase _phase = SpeedPhase.countdown;
  int _countdown = 3;
  int _secondsLeft = AppConfig.speedRoundSeconds;
  Timer? _countdownTimer;
  Timer? _gameTimer;

  final List<_WordEntry> _words = [];
  int _combo = 1;
  int _maxCombo = 1;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          t.cancel();
          _startGame();
        }
      });
    });
  }

  void _startGame() {
    setState(() => _phase = SpeedPhase.playing);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          t.cancel();
          _endGame();
        }
      });
    });
  }

  void _onSubmitWord(String raw) {
    if (_phase != SpeedPhase.playing) return;
    final word = raw.trim().toUpperCase();
    _controller.clear();

    if (word.length < AppConfig.minWordLength) return;

    final alreadyUsed = _words.any((w) => w.word == word && w.valid);
    if (alreadyUsed) {
      _addWord(word, valid: false, reason: 'duplicate');
      return;
    }

    final isValid = HiveService.isValidWord(word);
    if (isValid) {
      _combo++;
      _maxCombo = _combo > _maxCombo ? _combo : _maxCombo;
      final wordScore = word.length * _combo;
      _score += wordScore;
      _addWord(word, valid: true);
      HapticFeedback.selectionClick();
    } else {
      _combo = 1;
      _addWord(word, valid: false, reason: 'invalid');
    }
  }

  void _addWord(String word, {required bool valid, String? reason}) {
    setState(() {
      _words.insert(0, _WordEntry(word: word, valid: valid, reason: reason));
    });
  }

  void _endGame() {
    setState(() => _phase = SpeedPhase.finished);
    final validWords = _words.where((w) => w.valid).toList();
    final lastWord = validWords.isNotEmpty ? validWords.first.word : 'HIZLI';

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final result = GameResult(
        mode: GameMode.speed,
        outcome: GameOutcome.win,
        score: _score,
        word: lastWord,
        wordsCount: validWords.length,
        durationSeconds: AppConfig.speedRoundSeconds - _secondsLeft,
      );
      context.push(AppRoutes.tdkReveal, extra: TdkRevealExtra(
        word: lastWord,
        gameResult: result,
      ));
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _gameTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final s = S.of(context);

    if (_phase == SpeedPhase.countdown) {
      return _CountdownView(countdown: _countdown, s: s);
    }

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: Text(s.speedTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              // Timer + stats
              Row(
                children: [
                  // Timer
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      '$_secondsLeft',
                      key: ValueKey(_secondsLeft),
                      style: AppTheme.gameTimer.copyWith(
                        color: _secondsLeft <= 10 ? AppTheme.error : AppTheme.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Word count
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${_words.where((w) => w.valid).length} ${s.speedWords}',
                        style: AppTheme.headlineMedium.copyWith(color: AppTheme.accent)),
                      if (_combo > 2)
                        Text('${s.speedCombo}$_combo',
                          style: AppTheme.labelMedium.copyWith(color: AppTheme.primary)),
                    ],
                  ),
                ],
              ),

              LinearProgressIndicator(
                value: _secondsLeft / AppConfig.speedRoundSeconds,
                backgroundColor: AppTheme.bgBorder,
                valueColor: AlwaysStoppedAnimation(
                  _secondsLeft <= 10 ? AppTheme.error : AppTheme.primary),
              ),

              const SizedBox(height: 16),

              // Word list
              Expanded(
                child: ListView.builder(
                  itemCount: _words.length,
                  itemBuilder: (_, i) {
                    final w = _words[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Icon(
                            w.valid ? Icons.check_rounded : Icons.close_rounded,
                            color: w.valid ? AppTheme.correct : AppTheme.error,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(w.word,
                            style: AppTheme.titleMedium.copyWith(
                              color: w.valid ? AppTheme.textPrimary : AppTheme.textHint)),
                        ],
                      ),
                    ).animate().fadeIn(duration: 200.ms);
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Input
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.characters,
                enabled: _phase == SpeedPhase.playing,
                onFieldSubmitted: _onSubmitWord,
                decoration: InputDecoration(
                  hintText: '...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: () => _onSubmitWord(_controller.text),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordEntry {
  const _WordEntry({required this.word, required this.valid, this.reason});
  final String word;
  final bool valid;
  final String? reason;
}

class _CountdownView extends StatelessWidget {
  const _CountdownView({required this.countdown, required this.s});
  final int countdown;
  final S s;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(countdown > 0 ? '$countdown' : s.speedGo,
              style: AppTheme.displayLarge.copyWith(
                fontSize: 96,
                color: countdown > 0 ? AppTheme.textPrimary : AppTheme.primary,
              ),
            ).animate(key: ValueKey(countdown))
              .scale(begin: const Offset(0.5, 0.5), duration: 400.ms)
              .fadeIn(duration: 300.ms),
            const SizedBox(height: 24),
            Text(s.speedGetReady,
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
