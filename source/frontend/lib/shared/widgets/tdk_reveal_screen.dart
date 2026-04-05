// lib/shared/widgets/tdk_reveal_screen.dart
//
// Kelimelik — TDK word reveal screen shown after every game round.
// Shows word meaning + example from TDK dictionary.
// Share to WhatsApp + Continue button (triggers ad, then goes to Result).

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/services/ad_service.dart';
import '../../core/services/tdk_service.dart';
import '../../core/theme/app_theme.dart';
import '../models/game_result.dart';

class TdkRevealScreen extends ConsumerWidget {
  const TdkRevealScreen({super.key, required this.extra});
  final TdkRevealExtra extra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);

    final wordInfoAsync = ref.watch(tdkWordInfoProvider(extra.word));

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Text(s.tdkTitle,
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.primary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                extra.word.toUpperCase(),
                style: AppTheme.displayLarge.copyWith(color: AppTheme.textPrimary),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),

              const SizedBox(height: 32),

              // ── TDK Definition ───────────────────────────────────────────────
              Expanded(
                child: wordInfoAsync.when(
                  loading: () => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: AppTheme.primary),
                        const SizedBox(height: 12),
                        Text(s.commonLoading, style: AppTheme.bodyMedium),
                      ],
                    ),
                  ),
                  error: (_, __) => _NoDefinition(s: s),
                  data: (info) {
                    if (!info.hasDefinition) return _NoDefinition(s: s);
                    return _DefinitionContent(info: info, s: s);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ── Action Buttons ───────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareOnWhatsApp(context, ref, s),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: Text(s.tdkChallenge),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _onContinue(context, ref),
                      child: Text(s.commonContinue),
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

  Future<void> _onContinue(BuildContext context, WidgetRef ref) async {
    // Trigger ad (if due), then navigate to result
    final adService = ref.read(adServiceProvider);
    await adService.onRoundCompleted();

    if (context.mounted) {
      context.go(AppRoutes.result, extra: ResultExtra(
        mode: extra.gameResult?.modeId ?? 'wordle',
        score: extra.gameResult?.score ?? 0,
        gameResult: extra.gameResult,
      ));
    }
  }

  void _shareOnWhatsApp(BuildContext context, WidgetRef ref, S s) {
    final word = extra.word.toUpperCase();
    final score = extra.gameResult?.score ?? 0;
    final challengeUrl = '${AppConfig.challengeBaseUrl}/${extra.word.toLowerCase()}';

    final text = '''Kelimelik 🔤
$word — $score puan

${s.tdkChallenge}? $challengeUrl''';

    Share.share(text);
  }
}

// ─── Definition Content ───────────────────────────────────────────────────────

class _DefinitionContent extends StatelessWidget {
  const _DefinitionContent({required this.info, required this.s});
  final TdkWordInfo info;
  final S s;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (info.wordType != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
            ),
            child: Text(info.wordType!,
              style: AppTheme.labelSmall.copyWith(color: AppTheme.primary)),
          ),

        const SizedBox(height: 16),

        Text(s.tdkMeaning,
          style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary)),
        const SizedBox(height: 6),
        Text(info.meaning ?? '',
          style: AppTheme.bodyLarge.copyWith(height: 1.6),
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

        if (info.example != null) ...[
          const SizedBox(height: 24),
          Text(s.tdkExample,
            style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgMid,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.bgBorder),
            ),
            child: Text(
              '"${info.example!}"',
              style: AppTheme.bodyMedium.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
          ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
        ],
      ],
    );
  }
}

class _NoDefinition extends StatelessWidget {
  const _NoDefinition({required this.s});
  final S s;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        s.tdkNoDefinition,
        style: AppTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
