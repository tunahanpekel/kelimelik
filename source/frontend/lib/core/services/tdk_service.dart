// lib/core/services/tdk_service.dart
//
// Kelimelik — TDK (Turkish Language Association) API integration.
// Fetches word meaning and example sentence.
// Falls back silently to cached data or empty state.

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'hive_service.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class TdkWordInfo {
  const TdkWordInfo({
    required this.word,
    this.wordType,
    this.meaning,
    this.example,
  });

  final String word;
  final String? wordType;   // e.g. 'isim', 'sıfat', 'fiil'
  final String? meaning;
  final String? example;

  bool get hasDefinition => meaning != null && meaning!.isNotEmpty;

  @override
  String toString() => 'TdkWordInfo($word: $meaning)';
}

// ─── Provider ────────────────────────────────────────────────────────────────

final tdkServiceProvider = Provider<TdkService>((ref) => TdkService());

final tdkWordInfoProvider = FutureProvider.family<TdkWordInfo, String>((ref, word) {
  return ref.read(tdkServiceProvider).fetchWordInfo(word);
});

// ─── Service ─────────────────────────────────────────────────────────────────

class TdkService {
  Future<TdkWordInfo> fetchWordInfo(String word) async {
    final lower = word.toLowerCase().trim();

    // 1. Check cache
    final cached = HiveService.getTdkCached(lower);
    if (cached != null) {
      return _parseWordInfo(lower, cached);
    }

    // 2. Fetch from TDK API
    try {
      final uri = Uri.parse('${AppConfig.tdkApiBaseUrl}?ara=$lower');
      final response = await http.get(uri).timeout(AppConfig.tdkRequestTimeout);

      if (response.statusCode == 200) {
        final dynamic body = json.decode(response.body);

        // TDK returns an error object if not found
        if (body is Map && body.containsKey('error')) {
          return TdkWordInfo(word: word);
        }

        if (body is List && body.isNotEmpty) {
          final data = body.first as Map<String, dynamic>;
          await HiveService.saveTdkCache(lower, data);
          return _parseWordInfo(lower, data);
        }
      }
    } catch (e) {
      // Silent fail — word games should not be blocked by TDK API
    }

    return TdkWordInfo(word: word);
  }

  TdkWordInfo _parseWordInfo(String word, Map<dynamic, dynamic> data) {
    try {
      // TDK response structure:
      // { "madde": "kelime", "tür": "isim", "anlam_icerik": [{"anlam": "...", "ornek": [{"ornek": "..."}]}] }
      final wordType = data['tür'] as String?;
      final meanings = data['anlam_icerik'] as List?;

      String? meaning;
      String? example;

      if (meanings != null && meanings.isNotEmpty) {
        final first = meanings.first as Map;
        meaning = first['anlam'] as String?;
        final examples = first['ornek'] as List?;
        if (examples != null && examples.isNotEmpty) {
          example = (examples.first as Map)['ornek'] as String?;
        }
      }

      // Clean up HTML tags that TDK sometimes returns
      meaning = _cleanText(meaning);
      example = _cleanText(example);

      return TdkWordInfo(
        word: word,
        wordType: wordType,
        meaning: meaning,
        example: example,
      );
    } catch (_) {
      return TdkWordInfo(word: word);
    }
  }

  String? _cleanText(String? text) {
    if (text == null) return null;
    // Remove HTML-like tags
    return text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}
