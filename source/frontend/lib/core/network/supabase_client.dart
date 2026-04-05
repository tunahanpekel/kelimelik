// lib/core/network/supabase_client.dart
//
// Kelimelik — Supabase client wrapper.
// Used only for: leaderboard reads/writes + Google OAuth.
// Credentials injected via --dart-define at build time.

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  SupabaseClientService._();

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient   get auth   => Supabase.instance.client.auth;

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url:      url,
      anonKey:  anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      debug: kDebugMode,
    );
  }

  // ── Table names ─────────────────────────────────────────────────────────────
  static const String tableUsers              = 'users';
  static const String tableLeaderboard        = 'leaderboard_entries';
  static const String tableWeeklyTournaments  = 'weekly_tournaments';

  // ── Week key helper ─────────────────────────────────────────────────────────
  /// Returns ISO week key like '2026-W13'
  static String getCurrentWeekKey() {
    final now = DateTime.now().toUtc();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
    final dayOfWeek = now.weekday;
    final weekNumber = ((dayOfYear - dayOfWeek + 10) / 7).floor();
    return '${now.year}-W${weekNumber.toString().padLeft(2, '0')}';
  }
}
