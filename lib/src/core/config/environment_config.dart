import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }

  static String get supabaseUrl =>
      dotenv.get('SUPABASE_URL', fallback: '');

  static String get supabaseAnonKey =>
      dotenv.get('SUPABASE_ANON_KEY', fallback: '');

  static String get environment =>
      dotenv.get('ENVIRONMENT', fallback: 'development');

  static bool get enableAnalytics =>
      dotenv.get('ENABLE_ANALYTICS', fallback: 'true') == 'true';

  static String get appName =>
      dotenv.get('APP_NAME', fallback: 'K53 Learner\'s License');

  static String get appVersion =>
      dotenv.get('APP_VERSION', fallback: '1.0.0');

  static bool get enableGamification =>
      dotenv.get('ENABLE_GAMIFICATION', fallback: 'true') == 'true';

  static bool get enableSharing =>
      dotenv.get('ENABLE_SHARING', fallback: 'true') == 'true';

  static bool get enableOfflineMode =>
      dotenv.get('ENABLE_OFFLINE_MODE', fallback: 'true') == 'true';

  static String get apiBaseUrl =>
      dotenv.get('API_BASE_URL', fallback: '');

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
}