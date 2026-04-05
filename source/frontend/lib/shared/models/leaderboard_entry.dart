// lib/shared/models/leaderboard_entry.dart
//
// Kelimelik — leaderboard entry model.

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.weeklyScore,
    required this.gamesPlayed,
    required this.tournamentWeek,
    this.avatarUrl,
    this.rank,
  });

  final String userId;
  final String displayName;
  final int weeklyScore;
  final int gamesPlayed;
  final String tournamentWeek;
  final String? avatarUrl;
  final int? rank; // computed client-side

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map, {int? rank}) {
    return LeaderboardEntry(
      userId:         map['user_id'] as String? ?? '',
      displayName:    map['display_name'] as String? ?? 'Anonim',
      weeklyScore:    map['weekly_score'] as int? ?? 0,
      gamesPlayed:    map['games_played'] as int? ?? 0,
      tournamentWeek: map['tournament_week'] as String? ?? '',
      avatarUrl:      map['avatar_url'] as String?,
      rank:           rank,
    );
  }

  Map<String, dynamic> toMap() => {
    'user_id':         userId,
    'display_name':    displayName,
    'weekly_score':    weeklyScore,
    'games_played':    gamesPlayed,
    'tournament_week': tournamentWeek,
    'avatar_url':      avatarUrl,
  };

  LeaderboardEntry copyWith({int? rank}) => LeaderboardEntry(
    userId:         userId,
    displayName:    displayName,
    weeklyScore:    weeklyScore,
    gamesPlayed:    gamesPlayed,
    tournamentWeek: tournamentWeek,
    avatarUrl:      avatarUrl,
    rank:           rank ?? this.rank,
  );
}
