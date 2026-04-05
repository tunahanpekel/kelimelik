// lib/features/leaderboard/presentation/leaderboard_screen.dart
//
// Kelimelik — Weekly tournament leaderboard.
// Reads from Supabase. Shows top 100 + user's own rank.
// Banner ad between position 5 and 6.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/leaderboard_entry.dart';
import '../../../shared/widgets/loading_overlay.dart';

// ─── Provider ────────────────────────────────────────────────────────────────

final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  try {
    final week = SupabaseClientService.getCurrentWeekKey();
    final response = await SupabaseClientService.client
        .from(SupabaseClientService.tableLeaderboard)
        .select('user_id, display_name, avatar_url, weekly_score, games_played, tournament_week')
        .eq('tournament_week', week)
        .order('weekly_score', ascending: false)
        .limit(100);

    final entries = (response as List).asMap().entries.map((e) {
      return LeaderboardEntry.fromMap(
        Map<String, dynamic>.from(e.value as Map),
        rank: e.key + 1,
      );
    }).toList();

    return entries;
  } catch (_) {
    return [];
  }
});

// ─── Screen ───────────────────────────────────────────────────────────────────

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final entriesAsync = ref.watch(leaderboardProvider);
    final currentUser = Supabase.instance.client.auth.currentUser;
    final weekKey = SupabaseClientService.getCurrentWeekKey();

    // Compute week end date display
    final daysLeft = _computeWeekDaysLeft();

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: Column(
          children: [
            Text(s.leaderboardTitle),
            Text('$daysLeft ${s.leaderboardDays} ${s.leaderboardTimeLeft}',
              style: AppTheme.labelSmall.copyWith(color: AppTheme.textSecondary)),
          ],
        ),
        centerTitle: true,
      ),
      body: entriesAsync.when(
        loading: () => _LeaderboardShimmer(),
        error: (_, __) => Center(
          child: Text(s.leaderboardOffline, style: AppTheme.bodyMedium)),
        data: (entries) {
          if (entries.isEmpty) {
            return EmptyView(
              emoji: '🏆',
              title: s.leaderboardEmpty,
              subtitle: s.leaderboardEmptySub,
              action: () => context.go('/game/wordle'),
              actionLabel: s.commonPlay,
            );
          }

          // Find current user's entry
          final myEntry = currentUser != null
              ? entries.where((e) => e.userId == currentUser.id).firstOrNull
              : null;

          return Column(
            children: [
              // List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => ref.invalidate(leaderboardProvider),
                  color: AppTheme.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: entries.length,
                    itemBuilder: (_, i) {
                      // Insert banner ad between rank 5 and 6
                      // (Banner ad placeholder — load real ad in production)
                      return _EntryRow(
                        entry: entries[i],
                        isCurrentUser: currentUser?.id == entries[i].userId,
                      ).animate().fadeIn(delay: Duration(milliseconds: i * 30));
                    },
                  ),
                ),
              ),

              // My rank sticky footer (if signed in and ranked)
              if (myEntry != null)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: AppTheme.bgMid,
                    border: Border(top: BorderSide(color: AppTheme.bgBorder)),
                  ),
                  child: Row(
                    children: [
                      Text('${s.leaderboardMyRank}: #${myEntry.rank}',
                        style: AppTheme.titleMedium.copyWith(color: AppTheme.accent)),
                      const Spacer(),
                      Text('${myEntry.weeklyScore} ${s.leaderboardPoints}',
                        style: AppTheme.labelLarge),
                    ],
                  ),
                ),

              // Sign-in CTA (if not signed in)
              if (currentUser == null)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.bgMid,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.bgBorder),
                  ),
                  child: Column(
                    children: [
                      Text(s.leaderboardSignIn,
                        style: AppTheme.bodyMedium, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _signInWithGoogle(context),
                          icon: const Icon(Icons.login_rounded, size: 18),
                          label: Text(s.leaderboardSignInCta),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _shareLeaderboard(context, s),
        backgroundColor: AppTheme.primary,
        label: Text(s.leaderboardShareCTA),
        icon: const Icon(Icons.share_rounded),
      ),
    );
  }

  int _computeWeekDaysLeft() {
    final now = DateTime.now();
    final sunday = now.add(Duration(days: 7 - now.weekday));
    return sunday.difference(now).inDays;
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AppConfig.deepLinkScheme,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  void _shareLeaderboard(BuildContext context, S s) {
    Share.share(
      'Kelimelik haftalık turnuvası! 🏆\n${s.tdkChallenge}?\n${AppConfig.challengeBaseUrl}'
    );
  }
}

// ─── Entry row ────────────────────────────────────────────────────────────────

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, required this.isCurrentUser});
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final rank = entry.rank ?? 0;
    final isPodium = rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppTheme.primary.withValues(alpha: 0.1)
            : AppTheme.bgMid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentUser ? AppTheme.primary.withValues(alpha: 0.4) : AppTheme.bgBorder,
          width: isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 36,
            child: Center(
              child: isPodium
                  ? Text(['🥇', '🥈', '🥉'][rank - 1], style: const TextStyle(fontSize: 20))
                  : Text('$rank',
                      style: AppTheme.labelLarge.copyWith(
                        color: rank <= 10 ? AppTheme.accent : AppTheme.textHint)),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.bgSurface,
            backgroundImage: entry.avatarUrl != null
                ? NetworkImage(entry.avatarUrl!) : null,
            child: entry.avatarUrl == null
                ? Text(entry.displayName[0].toUpperCase(),
                    style: AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary))
                : null,
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.displayName,
                  style: AppTheme.titleMedium.copyWith(
                    color: isCurrentUser ? AppTheme.textPrimary : AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
                Text('${entry.gamesPlayed} ${S.of(context).leaderboardGames}',
                  style: AppTheme.labelSmall),
              ],
            ),
          ),

          // Score
          Text('${entry.weeklyScore}',
            style: AppTheme.titleLarge.copyWith(
              color: isPodium ? AppTheme.accent : AppTheme.textPrimary)),
        ],
      ),
    );
  }
}

// ─── Shimmer ──────────────────────────────────────────────────────────────────

class _LeaderboardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.bgMid,
      highlightColor: AppTheme.bgSurface,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.bgMid,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
