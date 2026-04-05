// lib/core/config/app_config.dart
//
// Kelimelik — App configuration.
// All credentials injected via --dart-define at build time.
// Never hardcode real values here.
//
// Run locally:
//   flutter run \
//     --dart-define=APP_ENV=dev \
//     --dart-define=SUPABASE_URL=https://xxx.supabase.co \
//     --dart-define=SUPABASE_ANON_KEY=eyJ... \
//     --dart-define=ADMOB_ANDROID_APP_ID=ca-app-pub-xxx \
//     --dart-define=ADMOB_IOS_APP_ID=ca-app-pub-xxx

class AppConfig {
  AppConfig._();

  static const String appName = 'Kelimelik';
  static const String packageId = 'com.kelimelik.app';

  // ── Environment ──────────────────────────────────────────────────────────────
  static const String env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  static bool get isProduction => env == 'production';
  static bool get isStaging => env == 'staging';
  static bool get isDev => env == 'dev';

  // ── Supabase ─────────────────────────────────────────────────────────────────
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: 'YOUR_SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'YOUR_SUPABASE_ANON_KEY');

  // ── AdMob ────────────────────────────────────────────────────────────────────
  static const String admobAndroidAppId =
      String.fromEnvironment('ADMOB_ANDROID_APP_ID', defaultValue: 'ca-app-pub-3940256099942544~3347511713');
  static const String admobIosAppId =
      String.fromEnvironment('ADMOB_IOS_APP_ID', defaultValue: 'ca-app-pub-3940256099942544~1458002511');

  // Ad unit IDs — test IDs as defaults (replace with real IDs in production)
  static const String admobAndroidInterstitialId =
      String.fromEnvironment('ADMOB_ANDROID_INTERSTITIAL_ID', defaultValue: 'ca-app-pub-3940256099942544/4411468910');
  static const String admobIosInterstitialId =
      String.fromEnvironment('ADMOB_IOS_INTERSTITIAL_ID', defaultValue: 'ca-app-pub-3940256099942544/4411468910');
  static const String admobAndroidBannerId =
      String.fromEnvironment('ADMOB_ANDROID_BANNER_ID', defaultValue: 'ca-app-pub-3940256099942544/6300978111');
  static const String admobIosBannerId =
      String.fromEnvironment('ADMOB_IOS_BANNER_ID', defaultValue: 'ca-app-pub-3940256099942544/2934735716');

  // ── TDK API ──────────────────────────────────────────────────────────────────
  static const String tdkApiBaseUrl = 'https://sozluk.gov.tr/gts';
  static const Duration tdkCacheDuration = Duration(days: 7);
  static const Duration tdkRequestTimeout = Duration(seconds: 5);

  // ── Game Config ───────────────────────────────────────────────────────────────
  static const int wordleWordLength = 5;
  static const int wordleMaxAttempts = 6;
  static const int speedRoundSeconds = 60;
  static const int chainRoundSeconds = 30; // per word
  static const int categoryRoundSeconds = 90;
  static const int minWordLength = 3;

  // ── Ad Frequency ─────────────────────────────────────────────────────────────
  static const int interstitialMinIntervalSeconds = 120; // 2 minutes between interstitials
  static const int gamesBeforeFirstInterstitial = 2;

  // ── Deep Links ───────────────────────────────────────────────────────────────
  static const String deepLinkScheme = 'com.kelimelik.app://login-callback';
  static const String challengeBaseUrl = 'https://kelimelik.app/challenge';
  static const String privacyPolicyUrl = 'https://kelimelik.app/privacy';
  static const String termsUrl = 'https://kelimelik.app/terms';
}
