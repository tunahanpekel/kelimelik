// lib/core/services/ad_service.dart
//
// Kelimelik — AdMob interstitial + banner ad management.
// Interstitial shown only at natural round transitions (after TDK reveal).
// Frequency cap: 1 per 2 minutes, first one after 2 completed games.

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/app_config.dart';

// ─── Provider ────────────────────────────────────────────────────────────────

final adServiceProvider = Provider<AdService>((ref) => AdService());

// ─── Ad Service ───────────────────────────────────────────────────────────────

class AdService {
  InterstitialAd? _interstitial;
  DateTime? _lastInterstitialTime;
  int _completedGames = 0;
  bool _isLoading = false;

  String get _interstitialAdUnitId => Platform.isIOS
      ? AppConfig.admobIosInterstitialId
      : AppConfig.admobAndroidInterstitialId;

  String get _bannerAdUnitId => Platform.isIOS
      ? AppConfig.admobIosBannerId
      : AppConfig.admobAndroidBannerId;

  /// Call this at app startup
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    if (kDebugMode) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: ['YOUR_TEST_DEVICE_ID'],
        ),
      );
    }
  }

  /// Pre-load next interstitial (call after showing one)
  Future<void> loadInterstitial() async {
    if (_isLoading || _interstitial != null) return;
    _isLoading = true;

    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _isLoading = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitial = null;
              loadInterstitial(); // pre-load next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitial = null;
              loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          debugPrint('Interstitial failed to load: $error');
        },
      ),
    );
  }

  /// Call when a game round completes. Returns true if ad was shown.
  Future<bool> onRoundCompleted() async {
    _completedGames++;

    if (_completedGames < AppConfig.gamesBeforeFirstInterstitial) {
      return false;
    }

    final now = DateTime.now();
    if (_lastInterstitialTime != null) {
      final elapsed = now.difference(_lastInterstitialTime!).inSeconds;
      if (elapsed < AppConfig.interstitialMinIntervalSeconds) {
        return false;
      }
    }

    return await _showInterstitial();
  }

  Future<bool> _showInterstitial() async {
    if (_interstitial == null) {
      await loadInterstitial();
      return false; // will show next time
    }

    _lastInterstitialTime = DateTime.now();
    await _interstitial!.show();
    return true;
  }

  /// Create a banner ad widget
  AdWidget createBannerAd() {
    final banner = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner failed to load: $error');
        },
      ),
    )..load();
    return AdWidget(ad: banner);
  }

  void dispose() {
    _interstitial?.dispose();
  }
}
