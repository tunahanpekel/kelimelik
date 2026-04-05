// lib/shared/widgets/result_screen.dart
//
// Kelimelik — universal result screen shown after TDK reveal + ad.
// Shows score, best score, play again / go home options.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/services/hive_service.dart';
import '../../core/theme/app_theme.dart';
import '../models/game_result.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key, required this.extra});
  final ResultExtra extra;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late Map<String, dynamic> _modeScores;
  bool _isNewRecord = false;

  @override
  void initState() {
    super.initState();
    _modeScores = HiveService.getScores(widget.extra.mode);
    final oldBest = _modeScores['best'] as int;
    _isNewRecord = widget.extra.score > oldBest;

    // Save score
    HiveService.saveScore(
      widget.extra.mode,
      widget.extra.score,
      widget.extra.gameResult?.isWin ?? false,
    );

    // Update streak if won
    if (widget.extra.gameResult?.isWin == true) {
      HiveService.updateStreak();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final result = widget.extra.gameResult;

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            children: [
              // ── Score ──────────────────────────────────────────────────────
              if (_isNewRecord)
                Text(s.resultNewRecord,
                  style: AppTheme.titleLarge.copyWith(color: AppTheme.accent))
                  .animate().fadeIn().shimmer(color: AppTheme.accent),

              const SizedBox(height: 16),

              Text(s.resultScore,
                style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              Text(
                widget.extra.score.toString(),
                style: AppTheme.scoreDisplay,
              ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.7, 0.7)),

              const SizedBox(height: 8),
              Text(
                '${s.resultBestScore}: ${_isNewRecord ? widget.extra.score : _modeScores['best']}',
                style: AppTheme.bodyMedium,
              ),

              const SizedBox(height: 32),

              // ── Stats ──────────────────────────────────────────────────────
              if (result != null)
                _StatsRow(result: result),

              const Spacer(),

              // ── Action Buttons ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => _playAgain(context),
                  child: Text(s.commonPlayAgain),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareOnWhatsApp(s),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: Text(s.resultWhatsapp),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go(AppRoutes.home),
                      child: Text(s.resultGoHome),
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

  void _playAgain(BuildContext context) {
    final mode = widget.extra.mode;
    final routes = {
      'wordle':   AppRoutes.gameWordle,
      'chain':    AppRoutes.gameChain,
      'anagram':  AppRoutes.gameAnagram,
      'speed':    AppRoutes.gameSpeed,
      'category': AppRoutes.gameCategory,
    };
    context.go(routes[mode] ?? AppRoutes.home);
  }

  void _shareOnWhatsApp(S s) {
    final score = widget.extra.score;
    final mode = widget.extra.mode;
    final text = '''Kelimelik 🔤 — $mode
${s.resultScore}: $score
${s.resultBestScore}: ${_modeScores['best']}

${s.tdkChallenge}? ${AppConfig.challengeBaseUrl}''';

    Share.share(text);
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.result});
  final GameResult result;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bgBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (result.attemptsUsed != null)
            _StatItem(label: s.wordleAttempts, value: '${result.attemptsUsed}/6'),
          if (result.wordsCount != null)
            _StatItem(label: s.speedWords, value: '${result.wordsCount}'),
          if (result.chainLength != null)
            _StatItem(label: s.chainLength, value: '${result.chainLength}'),
          if (result.durationSeconds != null)
            _StatItem(label: s.resultDuration, value: '${result.durationSeconds}s'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTheme.headlineMedium.copyWith(color: AppTheme.accent)),
        const SizedBox(height: 2),
        Text(label, style: AppTheme.labelSmall),
      ],
    );
  }
}
