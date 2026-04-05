// lib/core/router/app_router.dart
//
// Kelimelik — GoRouter setup.
// No mandatory auth — home is always accessible.
// Sign-in is optional (leaderboard only).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../l10n/app_strings.dart';
import '../services/hive_service.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/game_wordle/presentation/wordle_screen.dart';
import '../../features/game_chain/presentation/chain_screen.dart';
import '../../features/game_anagram/presentation/anagram_screen.dart';
import '../../features/game_speed/presentation/speed_screen.dart';
import '../../features/game_category/presentation/category_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/widgets/tdk_reveal_screen.dart';
import '../../shared/widgets/result_screen.dart';
import '../../shared/models/game_result.dart';

part 'app_router.g.dart';

// ─── Route paths ──────────────────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._();

  static const root        = '/';
  static const onboarding  = '/onboarding';
  static const home        = '/home';
  static const leaderboard = '/leaderboard';
  static const settings    = '/settings';
  static const gameWordle  = '/game/wordle';
  static const gameChain   = '/game/chain';
  static const gameAnagram = '/game/anagram';
  static const gameSpeed   = '/game/speed';
  static const gameCategory= '/game/category';
  static const tdkReveal   = '/tdk-reveal';
  static const result      = '/result';
}

// ─── Router ───────────────────────────────────────────────────────────────────

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: false,

    redirect: (context, state) {
      // Show onboarding on first launch
      if (!HiveService.hasSeenOnboarding &&
          state.matchedLocation != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }
      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.root,
        redirect: (_, __) => AppRoutes.home,
      ),

      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => _fadeTransition(
          state: state,
          child: const OnboardingScreen(),
        ),
      ),

      ShellRoute(
        builder: (context, state, child) => _ScaffoldWithNav(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => _fadeTransition(
              state: state,
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.leaderboard,
            name: 'leaderboard',
            pageBuilder: (context, state) => _fadeTransition(
              state: state,
              child: const LeaderboardScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) => _fadeTransition(
              state: state,
              child: const SettingsScreen(),
            ),
          ),
        ],
      ),

      // ── Game routes (full-screen, no nav bar) ────────────────────────────────
      GoRoute(
        path: AppRoutes.gameWordle,
        name: 'gameWordle',
        pageBuilder: (context, state) => _slideUpTransition(
          state: state,
          child: const WordleScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.gameChain,
        name: 'gameChain',
        pageBuilder: (context, state) => _slideUpTransition(
          state: state,
          child: const ChainScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.gameAnagram,
        name: 'gameAnagram',
        pageBuilder: (context, state) => _slideUpTransition(
          state: state,
          child: const AnagramScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.gameSpeed,
        name: 'gameSpeed',
        pageBuilder: (context, state) => _slideUpTransition(
          state: state,
          child: const SpeedScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.gameCategory,
        name: 'gameCategory',
        pageBuilder: (context, state) => _slideUpTransition(
          state: state,
          child: CategoryScreen(
            category: state.extra as String? ?? 'Hayvanlar',
          ),
        ),
      ),

      // ── Post-game screens ────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.tdkReveal,
        name: 'tdkReveal',
        pageBuilder: (context, state) => _slideUpTransition(
          state: state,
          child: TdkRevealScreen(
            extra: state.extra as TdkRevealExtra? ?? const TdkRevealExtra(word: ''),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.result,
        name: 'result',
        pageBuilder: (context, state) => _fadeTransition(
          state: state,
          child: ResultScreen(
            extra: state.extra as ResultExtra? ?? const ResultExtra(mode: 'wordle', score: 0),
          ),
        ),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 16),
            Text(S.of(context).commonPageNotFound),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: Text(S.of(context).commonGoHome),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─── Shell with bottom nav bar ────────────────────────────────────────────────

class _ScaffoldWithNav extends ConsumerWidget {
  const _ScaffoldWithNav({required this.child});
  final Widget child;

  static const _tabs = [
    AppRoutes.home,
    AppRoutes.leaderboard,
    AppRoutes.settings,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabs.indexWhere((t) => location.startsWith(t));

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex < 0 ? 0 : currentIndex,
        onTap: (i) => context.go(_tabs[i]),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            activeIcon: const Icon(Icons.home_rounded),
            label: s.tabHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.leaderboard_rounded),
            activeIcon: const Icon(Icons.leaderboard_rounded),
            label: s.tabLeaderboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_rounded),
            activeIcon: const Icon(Icons.settings_rounded),
            label: s.tabSettings,
          ),
        ],
      ),
    );
  }
}

// ─── Transition helpers ───────────────────────────────────────────────────────

CustomTransitionPage<void> _slideUpTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    fullscreenDialog: true,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

CustomTransitionPage<void> _fadeTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
