// lib/features/onboarding/presentation/onboarding_screen.dart
//
// Kelimelik — 3-slide onboarding with optional Google Sign-In.
// Google sign-in is for leaderboard only — users can skip and play as guest.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  bool _isSigningIn = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _continueWithGoogle(S s) async {
    setState(() => _isSigningIn = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: AppConfig.deepLinkScheme,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      // Auth state change → router redirects automatically
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${s.commonError}: $e'),
          backgroundColor: AppTheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  void _playAsGuest() {
    HiveService.markOnboardingSeen();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final s = S.of(context);

    final pages = [
      _PageData(
        emoji: '🔤',
        title: s.onboarding1Title,
        subtitle: s.onboarding1Subtitle,
        gradient: const [Color(0xFF1A0A0E), Color(0xFF0D1117)],
      ),
      _PageData(
        emoji: '🎮',
        title: s.onboarding2Title,
        subtitle: s.onboarding2Subtitle,
        gradient: const [Color(0xFF0A1A0E), Color(0xFF0D1117)],
      ),
      _PageData(
        emoji: '🏆',
        title: s.onboarding3Title,
        subtitle: s.onboarding3Subtitle,
        gradient: const [Color(0xFF0E0E1A), Color(0xFF0D1117)],
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Page content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: pages.length,
            itemBuilder: (_, i) => _PageContent(page: pages[i]),
          ),

          // Bottom controls
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  children: [
                    // Progress dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(pages.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: _page == i ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: _page == i ? AppTheme.primary : AppTheme.bgBorder,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    if (_page < pages.length - 1) ...[
                      SizedBox(
                        width: double.infinity, height: 54,
                        child: ElevatedButton(
                          onPressed: () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                          ),
                          child: Text(s.commonContinue),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => _pageController.animateToPage(
                          pages.length - 1,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                        ),
                        child: Text(s.onboardingSkip,
                          style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary)),
                      ),
                    ] else ...[
                      // Google Sign-In
                      SizedBox(
                        width: double.infinity, height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _isSigningIn ? null : () => _continueWithGoogle(s),
                          icon: _isSigningIn
                              ? const SizedBox(width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.login_rounded),
                          label: Text(_isSigningIn ? '...' : s.authSignInGoogle),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _playAsGuest,
                        child: Text(s.authPlayAsGuest,
                          style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageData {
  const _PageData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradient;
}

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page});
  final _PageData page;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: page.gradient,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 80, 32, 220),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(page.emoji, style: const TextStyle(fontSize: 72))
                .animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(height: 32),
              Text(page.title,
                style: AppTheme.displayMedium,
                textAlign: TextAlign.center)
                .animate().fadeIn(delay: 150.ms, duration: 500.ms),
              const SizedBox(height: 16),
              Text(page.subtitle,
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textSecondary, height: 1.6),
                textAlign: TextAlign.center)
                .animate().fadeIn(delay: 250.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
