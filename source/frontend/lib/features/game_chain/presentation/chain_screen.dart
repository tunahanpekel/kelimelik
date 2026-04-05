// lib/features/game_chain/presentation/chain_screen.dart
//
// Kelimelik — Kelime Zinciri (Word Chain) game.
// Each word must start with the last letter of the previous word.

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

class ChainScreen extends ConsumerStatefulWidget {
  const ChainScreen({super.key});

  @override
  ConsumerState<ChainScreen> createState() => _ChainScreenState();
}

class _ChainScreenState extends ConsumerState<ChainScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final List<String> _chain = [];
  final Set<String> _usedWords = {};
  String _requiredLetter = '';
  String? _errorMessage;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _startGame();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  void _startGame() {
    // Pick a random starting word
    final words = HiveService.fiveLetterWords;
    if (words.isNotEmpty) {
      final startWord = words[DateTime.now().millisecondsSinceEpoch % words.length].toUpperCase();
      _chain.add(startWord);
      _usedWords.add(startWord);
      _requiredLetter = startWord[startWord.length - 1];
    } else {
      _requiredLetter = 'A';
    }
  }

  void _onSubmit() {
    final s = S.of(context);
    final word = _controller.text.trim().toUpperCase();
    if (word.isEmpty) return;

    // Validations
    if (word.length < AppConfig.minWordLength) {
      _showError(s.wordleTooShort);
      HapticFeedback.lightImpact();
      return;
    }

    if (!word.startsWith(_requiredLetter)) {
      _showError(s.chainWrongStart);
      HapticFeedback.lightImpact();
      return;
    }

    if (_usedWords.contains(word)) {
      _showError(s.chainAlreadyUsed);
      HapticFeedback.lightImpact();
      return;
    }

    if (!HiveService.isValidWord(word)) {
      _showError(s.wordleInvalidWord);
      HapticFeedback.lightImpact();
      return;
    }

    // Valid!
    setState(() {
      _chain.add(word);
      _usedWords.add(word);
      _requiredLetter = word[word.length - 1];
      _errorMessage = null;
      _controller.clear();
    });
    HapticFeedback.selectionClick();
  }

  void _showError(String msg) {
    setState(() => _errorMessage = msg);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _errorMessage = null);
    });
  }

  void _endGame() {
    final result = GameResult(
      mode: GameMode.chain,
      outcome: GameOutcome.win,
      score: _chain.length * 50,
      word: _chain.last,
      chainLength: _chain.length,
    );
    context.push(AppRoutes.tdkReveal, extra: TdkRevealExtra(
      word: _chain.last,
      gameResult: result,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: Text(s.chainTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⛓️', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text('${_chain.length}',
                    style: AppTheme.titleMedium.copyWith(color: AppTheme.accentTeal)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Required letter display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.bgMid,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4), width: 2),
                ),
                child: Column(
                  children: [
                    Text(s.chainStartLetter,
                      style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Text(_requiredLetter,
                      style: AppTheme.displayLarge.copyWith(color: AppTheme.primary),
                    ).animate(key: ValueKey(_requiredLetter)).scale(begin: const Offset(0.5, 0.5), duration: 300.ms),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_errorMessage!, style: AppTheme.labelLarge.copyWith(color: AppTheme.error)),
                ).animate().fadeIn(duration: 200.ms),

              // Chain history
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: _chain.length,
                  itemBuilder: (_, i) {
                    final word = _chain[_chain.length - 1 - i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: i == 0 ? AppTheme.accentTeal.withValues(alpha: 0.2) : AppTheme.bgSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text('${_chain.length - i}',
                                style: AppTheme.labelSmall.copyWith(
                                  color: i == 0 ? AppTheme.accentTeal : AppTheme.textHint)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(word,
                            style: i == 0
                              ? AppTheme.titleLarge.copyWith(color: AppTheme.accentTeal)
                              : AppTheme.bodyMedium),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textCapitalization: TextCapitalization.characters,
                      onSubmitted: (_) => _onSubmit(),
                      decoration: InputDecoration(
                        hintText: '$_requiredLetter...',
                        prefixText: '$_requiredLetter',
                        prefixStyle: AppTheme.titleMedium.copyWith(color: AppTheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _onSubmit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(56, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.arrow_forward_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _chain.length >= 3 ? _endGame : null,
                  child: Text('${s.chainLength}: ${_chain.length} — ${s.commonContinue}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
