// lib/core/services/hive_service.dart
//
// Kelimelik — Hive local storage service.
// Manages: word database, TDK cache, scores, streaks, settings.

import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class HiveService {
  HiveService._();

  // ── Box names ────────────────────────────────────────────────────────────────
  static const String boxWords5Letter = 'words_5letter';
  static const String boxWordsAll     = 'words_all';
  static const String boxAnagramWords = 'words_anagram';
  static const String boxCategoryWords= 'category_words';
  static const String boxTdkCache     = 'tdk_cache';
  static const String boxScores       = 'scores';
  static const String boxStreaks      = 'streaks';
  static const String boxSettings     = 'settings';

  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Open all boxes
    await Future.wait([
      Hive.openBox<String>(boxWords5Letter),
      Hive.openBox<String>(boxWordsAll),
      Hive.openBox<String>(boxAnagramWords),
      Hive.openBox<List>(boxCategoryWords),
      Hive.openBox<Map>(boxTdkCache),
      Hive.openBox<Map>(boxScores),
      Hive.openBox<Map>(boxStreaks),
      Hive.openBox<dynamic>(boxSettings),
    ]);
  }

  // ── Word Database ────────────────────────────────────────────────────────────

  static List<String> get fiveLetterWords {
    final box = Hive.box<String>(boxWords5Letter);
    return box.values.toList();
  }

  static bool isValidWord(String word) {
    final lower = word.toLowerCase();
    final box = Hive.box<String>(boxWordsAll);
    return box.containsKey(lower);
  }

  static bool isValid5LetterWord(String word) {
    if (word.length != 5) return false;
    final lower = word.toLowerCase();
    final box = Hive.box<String>(boxWords5Letter);
    return box.containsKey(lower);
  }

  static List<String> getWordsForAnagram() {
    final box = Hive.box<String>(boxAnagramWords);
    return box.values.toList();
  }

  static List<String> getCategoryWords(String category) {
    final box = Hive.box<List>(boxCategoryWords);
    final words = box.get(category.toLowerCase()) ?? [];
    return List<String>.from(words);
  }

  // ── TDK Cache ────────────────────────────────────────────────────────────────

  static Map<String, dynamic>? getTdkCached(String word) {
    final box = Hive.box<Map>(boxTdkCache);
    final entry = box.get(word.toLowerCase());
    if (entry == null) return null;

    // Check TTL (7 days)
    final cachedAt = entry['cached_at'] as int?;
    if (cachedAt == null) return null;
    final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
    if (age > const Duration(days: 7).inMilliseconds) {
      box.delete(word.toLowerCase());
      return null;
    }

    return Map<String, dynamic>.from(entry);
  }

  static Future<void> saveTdkCache(String word, Map<String, dynamic> data) async {
    final box = Hive.box<Map>(boxTdkCache);
    await box.put(word.toLowerCase(), {
      ...data,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // ── Scores ───────────────────────────────────────────────────────────────────

  static Map<String, dynamic> getScores(String mode) {
    final box = Hive.box<Map>(boxScores);
    final data = box.get(mode);
    if (data == null) return {'best': 0, 'total': 0, 'games': 0, 'wins': 0};
    return Map<String, dynamic>.from(data);
  }

  static Future<void> saveScore(String mode, int score, bool won) async {
    final box = Hive.box<Map>(boxScores);
    final current = getScores(mode);
    final newData = {
      'best':  score > (current['best'] as int) ? score : current['best'],
      'total': (current['total'] as int) + score,
      'games': (current['games'] as int) + 1,
      'wins':  (current['wins'] as int) + (won ? 1 : 0),
    };
    await box.put(mode, newData);
  }

  // ── Streaks ──────────────────────────────────────────────────────────────────

  static int get currentStreak {
    final box = Hive.box<Map>(boxStreaks);
    final data = box.get('main');
    if (data == null) return 0;
    final lastPlayed = data['last_played'] as String?;
    if (lastPlayed == null) return 0;

    final last = DateTime.tryParse(lastPlayed);
    if (last == null) return 0;

    final today = DateTime.now();
    final diff = today.difference(last).inDays;
    if (diff > 1) return 0; // streak broken
    return data['current'] as int? ?? 0;
  }

  static int get bestStreak {
    final box = Hive.box<Map>(boxStreaks);
    final data = box.get('main');
    return data?['best'] as int? ?? 0;
  }

  static Future<void> updateStreak() async {
    final box = Hive.box<Map>(boxStreaks);
    final today = DateTime.now().toIso8601String().split('T')[0];
    final current = currentStreak;
    final newStreak = current + 1;
    final best = bestStreak;

    await box.put('main', {
      'current':     newStreak,
      'best':        newStreak > best ? newStreak : best,
      'last_played': today,
    });
  }

  // ── Settings ─────────────────────────────────────────────────────────────────

  static bool get soundEnabled {
    final box = Hive.box<dynamic>(boxSettings);
    return box.get('sound_enabled', defaultValue: true) as bool;
  }

  static Future<void> setSoundEnabled(bool value) async {
    final box = Hive.box<dynamic>(boxSettings);
    await box.put('sound_enabled', value);
  }

  static bool get hasSeenOnboarding {
    final box = Hive.box<dynamic>(boxSettings);
    return box.get('seen_onboarding', defaultValue: false) as bool;
  }

  static Future<void> markOnboardingSeen() async {
    final box = Hive.box<dynamic>(boxSettings);
    await box.put('seen_onboarding', true);
  }

  // ── Debug ─────────────────────────────────────────────────────────────────────

  static void debugPrintStats() {
    if (!kDebugMode) return;
    final w5 = Hive.box<String>(boxWords5Letter).length;
    final wAll = Hive.box<String>(boxWordsAll).length;
    debugPrint('[Hive] 5-letter words: $w5 | All words: $wAll');
  }
}
