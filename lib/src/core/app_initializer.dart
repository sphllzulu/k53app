import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:ui' as ui;
import './config/environment_config.dart';
import './services/supabase_service.dart';

class AppInitializer {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Load environment variables
    await EnvironmentConfig.initialize();

    // Initialize Supabase
    await SupabaseService.initialize();

    // Additional initialization can be added here:
    // - Analytics
    // - Crash reporting
    // - Local database
    // - Caching
    // - etc.
  }

  static Future<void> preCacheAssets(BuildContext context) async {
    // Pre-cache any assets that need to be loaded immediately
    // This can be called from the main widget's build method
  }

  static void setupErrorHandling() {
    // Setup global error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      // Log to analytics/crash reporting
      if (EnvironmentConfig.isDevelopment) {
        debugPrint('Flutter error: ${details.exception}');
      }
    };

    // Setup platform error handling
    ui.PlatformDispatcher.instance.onError = (error, stack) {
      // Log to analytics/crash reporting
      if (EnvironmentConfig.isDevelopment) {
        debugPrint('Platform error: $error\n$stack');
      }
      return true;
    };
  }
}