// lib/features/home/presentation/home_screen.dart
//
// Kelimelik — Home screen with 5 game mode cards + streak + banner ad.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: defaultTargetPlatform == TargetPlatform.iOS
          ? AppConfig.admobIosBannerId
          : AppConfig.admobAndroidBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _bannerLoaded = true),
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final streak = HiveService.currentStreak;

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: AppTheme.bgDeep,
                  floating: true,
                  title: Row(
                    children: [
                      Text(s.appName,
                        style: AppTheme.headlineLarge.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w800,
                        )),
                      const Spacer(),
                      if (streak > 0)
                        _StreakBadge(streak: streak),
                    ],
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Tagline
                      Text(s.homeTagline,
                        style: AppTheme.bodyMedium.copyWith(height: 1.4))
                        .animate().fadeIn(delay: 100.ms),

                      const SizedBox(height: 24),

                      // Daily Challenge — featured card
                      _DailyChallengCard(s: s)
                        .animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),

                      const SizedBox(height: 20),

                      // Section header
                      Text(s.homeSelectMode, style: AppTheme.titleLarge)
                        .animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 12),

                      // 2-column grid of remaining 4 modes
                      _ModeGrid(s: s)
                        .animate().fadeIn(delay: 250.ms),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // Banner ad
          if (_bannerLoaded && _bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}

// ─── Streak badge ─────────────────────────────────────────────────────────────

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text('$streak ${_streakLabel(context)}',
            style: AppTheme.labelMedium.copyWith(color: AppTheme.accent)),
        ],
      ),
    );
  }

  String _streakLabel(BuildContext context) {
    // "gün" in Turkish, "day" in English, etc.
    final lang = Localizations.localeOf(context).languageCode;
    return switch (lang) {
      'tr' => 'gün',
      'es' => 'días',
      'de' => 'Tage',
      'fr' => 'jours',
      'pt' => 'dias',
      _    => 'days',
    };
  }
}

// ─── Daily Challenge Card ─────────────────────────────────────────────────────

class _DailyChallengCard extends StatelessWidget {
  const _DailyChallengCard({required this.s});
  final S s;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.gameWordle),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Text('🔤', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.homeDailyChallenge,
                    style: AppTheme.labelMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 0.5,
                    )),
                  const SizedBox(height: 4),
                  Text(s.modeWordle,
                    style: AppTheme.headlineMedium.copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(s.modeWordleDesc,
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.7))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Mode Grid ────────────────────────────────────────────────────────────────

class _ModeGrid extends StatelessWidget {
  const _ModeGrid({required this.s});
  final S s;

  static const _categories = [
    'Hayvanlar', 'Yemekler', 'Şehirler', 'Meslekler',
  ];

  @override
  Widget build(BuildContext context) {
    final modes = [
      _ModeData(
        emoji: '⛓️',
        title: (S s) => s.modeChain,
        desc:  (S s) => s.modeChainDesc,
        color: AppTheme.accentTeal,
        route: AppRoutes.gameChain,
      ),
      _ModeData(
        emoji: '🔀',
        title: (S s) => s.modeAnagram,
        desc:  (S s) => s.modeAnagramDesc,
        color: AppTheme.accentPurple,
        route: AppRoutes.gameAnagram,
      ),
      _ModeData(
        emoji: '⚡',
        title: (S s) => s.modeSpeed,
        desc:  (S s) => s.modeSpeedDesc,
        color: AppTheme.accent,
        route: AppRoutes.gameSpeed,
      ),
      _ModeData(
        emoji: '🏷️',
        title: (S s) => s.modeCategory,
        desc:  (S s) => s.modeCategoryDesc,
        color: AppTheme.accentPurple,
        route: AppRoutes.gameCategory,
        extra: _categories[DateTime.now().day % _categories.length],
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: modes.map((m) => _ModeCard(mode: m, s: s)).toList(),
    );
  }
}

class _ModeData {
  const _ModeData({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.color,
    required this.route,
    this.extra,
  });
  final String emoji;
  final String Function(S) title;
  final String Function(S) desc;
  final Color color;
  final String route;
  final Object? extra;
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.mode, required this.s});
  final _ModeData mode;
  final S s;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(mode.route, extra: mode.extra),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgMid,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: mode.color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mode.emoji, style: const TextStyle(fontSize: 28)),
            const Spacer(),
            Text(mode.title(s), style: AppTheme.titleMedium.copyWith(
              color: mode.color,
            )),
            const SizedBox(height: 2),
            Text(mode.desc(s),
              style: AppTheme.labelSmall.copyWith(height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
