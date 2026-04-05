// lib/features/settings/presentation/settings_screen.dart
//
// Kelimelik — Settings screen.
// Language selector, account (Google sign-in/out), stats, legal links.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(title: Text(s.tabSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [

          // ── Profile ──────────────────────────────────────────────────────
          _SectionHeader(title: s.settingsAccount),
          _ProfileCard(user: user),
          const SizedBox(height: 24),

          // ── Language ─────────────────────────────────────────────────────
          _SectionHeader(title: s.settingsLanguage),
          _LanguageCard(),
          const SizedBox(height: 24),

          // ── Statistics ───────────────────────────────────────────────────
          _SectionHeader(title: s.settingsStats),
          _StatsCard(s: s),
          const SizedBox(height: 24),

          // ── Account / Legal ───────────────────────────────────────────────
          _SectionHeader(title: s.settingsLegal),
          _SettingsCard(
            children: [
              _TapTile(
                icon: Icons.privacy_tip_rounded,
                iconColor: AppTheme.textSecondary,
                title: s.settingsPrivacy,
                onTap: () => _launchUrl(AppConfig.privacyPolicyUrl),
              ),
              const Divider(color: AppTheme.bgBorder, height: 1),
              _TapTile(
                icon: Icons.article_rounded,
                iconColor: AppTheme.textSecondary,
                title: s.settingsTerms,
                onTap: () => _launchUrl(AppConfig.termsUrl),
              ),
              if (user == null) ...[
                const Divider(color: AppTheme.bgBorder, height: 1),
                _TapTile(
                  icon: Icons.login_rounded,
                  iconColor: AppTheme.primary,
                  title: s.authSignIn,
                  onTap: () => _signInWithGoogle(context),
                ),
              ] else ...[
                const Divider(color: AppTheme.bgBorder, height: 1),
                _TapTile(
                  icon: Icons.logout_rounded,
                  iconColor: AppTheme.error,
                  title: s.authSignOut,
                  titleColor: AppTheme.error,
                  onTap: () async {
                    await Supabase.instance.client.auth.signOut();
                  },
                ),
                const Divider(color: AppTheme.bgBorder, height: 1),
                _TapTile(
                  icon: Icons.delete_outline_rounded,
                  iconColor: AppTheme.error,
                  title: s.settingsDeleteAccount,
                  titleColor: AppTheme.error,
                  onTap: () => _confirmDeleteAccount(context, s),
                ),
              ],
            ],
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              '${AppConfig.appName} v1.0.0',
              style: AppTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AppConfig.deepLinkScheme,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<void> _launchUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void _confirmDeleteAccount(BuildContext context, S s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgMid,
        title: Text(s.settingsDeleteAccount),
        content: Text(s.settingsDeleteAccountWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Supabase.instance.client.auth.signOut();
            },
            child: Text(s.settingsDeleteAccount,
              style: const TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Card ───────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.s});
  final S s;

  @override
  Widget build(BuildContext context) {
    final wordleScores = HiveService.getScores('wordle');
    final totalGames = (wordleScores['games'] as int? ?? 0)
        + (HiveService.getScores('chain')['games'] as int? ?? 0)
        + (HiveService.getScores('anagram')['games'] as int? ?? 0)
        + (HiveService.getScores('speed')['games'] as int? ?? 0)
        + (HiveService.getScores('category')['games'] as int? ?? 0);

    final wordleWins = wordleScores['wins'] as int? ?? 0;
    final wordleGames = wordleScores['games'] as int? ?? 0;
    final winRate = wordleGames > 0 ? (wordleWins / wordleGames * 100).round() : 0;
    final bestStreak = HiveService.bestStreak;

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
          _StatItem(label: s.settingsTotalGames, value: '$totalGames'),
          _Divider(),
          _StatItem(label: s.settingsWinRate, value: '%$winRate'),
          _Divider(),
          _StatItem(label: s.settingsBestStreak, value: '🔥$bestStreak'),
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
        Text(label, style: AppTheme.labelSmall, textAlign: TextAlign.center),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: AppTheme.bgBorder);
  }
}

// ─── Language Card ────────────────────────────────────────────────────────────

class _LanguageCard extends ConsumerStatefulWidget {
  const _LanguageCard();

  @override
  ConsumerState<_LanguageCard> createState() => _LanguageCardState();
}

class _LanguageCardState extends ConsumerState<_LanguageCard> {
  bool _expanded = false;

  static const _langs = [
    ('tr', '🇹🇷', 'Türkçe'),
    ('en', '🇬🇧', 'English'),
    ('es', '🇪🇸', 'Español'),
    ('de', '🇩🇪', 'Deutsch'),
    ('fr', '🇫🇷', 'Français'),
    ('pt', '🇵🇹', 'Português'),
  ];

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final s = S.of(context);
    final current = locale.languageCode;
    final currentLang = _langs.firstWhere((l) => l.$1 == current, orElse: () => _langs.first);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bgBorder),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.language_rounded, color: AppTheme.primary, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Text(s.settingsLanguage, style: AppTheme.titleMedium)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(currentLang.$2, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(currentLang.$3,
                          style: AppTheme.labelMedium.copyWith(color: AppTheme.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.textHint, size: 20),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const Divider(color: AppTheme.bgBorder, height: 1),
                ...List.generate(_langs.length, (i) {
                  final lang = _langs[i];
                  final isSelected = current == lang.$1;
                  return Column(
                    children: [
                      if (i > 0) const Divider(color: AppTheme.bgBorder, height: 1, indent: 16, endIndent: 16),
                      InkWell(
                        onTap: () {
                          ref.read(localeProvider.notifier).setLocale(lang.$1);
                          setState(() => _expanded = false);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Text(lang.$2, style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(lang.$3,
                                  style: AppTheme.titleMedium.copyWith(
                                    color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_rounded, color: AppTheme.primary, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable UI ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: AppTheme.titleLarge),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final email = user?.email ?? s.authPlayAsGuest;
    final name  = user?.userMetadata?['full_name'] as String? ?? 'Kelimelik';
    final avatar = user?.userMetadata?['avatar_url'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bgBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.bgSurface,
            backgroundImage: avatar != null ? NetworkImage(avatar) : null,
            child: avatar == null
                ? const Text('🔤', style: TextStyle(fontSize: 24))
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.titleMedium),
                const SizedBox(height: 2),
                Text(email, style: AppTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bgBorder),
      ),
      child: Column(children: children),
    );
  }
}

class _TapTile extends StatelessWidget {
  const _TapTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.titleColor,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                style: AppTheme.titleMedium.copyWith(
                  color: titleColor ?? AppTheme.textPrimary)),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}
