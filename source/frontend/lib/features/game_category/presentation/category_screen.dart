// lib/features/game_category/presentation/category_screen.dart
//
// Kelimelik — Kategori Modu (Category Mode).
// Name words belonging to the given thematic category in 90 seconds.

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

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key, required this.category});
  final String category;

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  int _secondsLeft = AppConfig.categoryRoundSeconds;
  Timer? _timer;
  List<String> _validAnswers = [];
  final List<String> _submitted = [];
  final List<bool> _results = [];
  int _score = 0;
  bool _passUsed = false;

  @override
  void initState() {
    super.initState();
    _validAnswers = HiveService.getCategoryWords(widget.category);
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          t.cancel();
          _endGame();
        }
      });
    });
  }

  void _onSubmit(String raw) {
    final word = raw.trim().toUpperCase();
    _controller.clear();
    if (word.isEmpty || word.length < 2) return;

    if (_submitted.contains(word)) {
      return; // silently skip duplicates
    }

    final isCorrect = _validAnswers.contains(word);
    setState(() {
      _submitted.insert(0, word);
      _results.insert(0, isCorrect);
      if (isCorrect) {
        _score += word.length * 10;
        HapticFeedback.selectionClick();
      }
    });
  }

  void _endGame() {
    final correctWords = _submitted.where((w) => _validAnswers.contains(w)).toList();
    final lastWord = correctWords.isNotEmpty ? correctWords.first : widget.category;

    final result = GameResult(
      mode: GameMode.category,
      outcome: GameOutcome.win,
      score: _score,
      word: lastWord,
      wordsCount: correctWords.length,
    );
    context.push(AppRoutes.tdkReveal, extra: TdkRevealExtra(
      word: lastWord,
      gameResult: result,
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final correctCount = _results.where((r) => r).length;

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: Text(s.categoryTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timer + score
              Row(
                children: [
                  Text('$_secondsLeft',
                    style: AppTheme.gameTimer.copyWith(
                      color: _secondsLeft <= 15 ? AppTheme.error : AppTheme.primary)),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$correctCount/${_validAnswers.length}',
                        style: AppTheme.headlineMedium.copyWith(color: AppTheme.accent)),
                      Text(s.resultScore + ': $_score',
                        style: AppTheme.labelSmall),
                    ],
                  ),
                ],
              ),
              LinearProgressIndicator(
                value: _secondsLeft / AppConfig.categoryRoundSeconds,
                backgroundColor: AppTheme.bgBorder,
                valueColor: AlwaysStoppedAnimation(
                  _secondsLeft <= 15 ? AppTheme.error : AppTheme.primary),
              ),

              const SizedBox(height: 16),

              // Category card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.bgMid,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.accentPurple.withValues(alpha: 0.4), width: 2),
                ),
                child: Column(
                  children: [
                    Text(s.categoryTitle,
                      style: AppTheme.labelSmall.copyWith(color: AppTheme.textSecondary, letterSpacing: 1.5)),
                    const SizedBox(height: 6),
                    Text(widget.category,
                      style: AppTheme.headlineLarge.copyWith(color: AppTheme.accentPurple)),
                    const SizedBox(height: 4),
                    Text(s.categoryInstruct,
                      style: AppTheme.bodyMedium,
                      textAlign: TextAlign.center),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 16),

              // Submitted words
              Expanded(
                child: ListView.builder(
                  itemCount: _submitted.length,
                  itemBuilder: (_, i) {
                    final word = _submitted[i];
                    final correct = _results[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Icon(
                            correct ? Icons.check_rounded : Icons.close_rounded,
                            color: correct ? AppTheme.correct : AppTheme.error,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(word,
                            style: AppTheme.titleMedium.copyWith(
                              color: correct ? AppTheme.textPrimary : AppTheme.textHint)),
                          if (correct) ...[
                            const Spacer(),
                            Text('+${word.length * 10}',
                              style: AppTheme.labelSmall.copyWith(color: AppTheme.accent)),
                          ],
                        ],
                      ),
                    ).animate().fadeIn(duration: 200.ms);
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textCapitalization: TextCapitalization.characters,
                      onSubmitted: _onSubmit,
                      decoration: const InputDecoration(hintText: '...'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _onSubmit(_controller.text),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (!_passUsed)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _passUsed = true);
                      _endGame();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                    ),
                    child: Text(s.categoryPass),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
