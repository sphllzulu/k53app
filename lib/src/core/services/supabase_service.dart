import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/environment_config.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: EnvironmentConfig.supabaseUrl,
      anonKey: EnvironmentConfig.supabaseAnonKey,
      debug: EnvironmentConfig.isDevelopment,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  static bool get isInitialized => Supabase.instance != null;

  // Helper method to check if user is authenticated
  static bool get isAuthenticated => auth.currentSession != null;

  // Get current user ID
  static String? get currentUserId => auth.currentUser?.id;

  // Get current user email
  static String? get currentUserEmail => auth.currentUser?.email;

  // Stream for auth state changes
  static Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  // Sign out method
  static Future<void> signOut() async {
    await auth.signOut();
  }

  // Error handling wrapper for Supabase operations
  static Future<T> executeWithErrorHandling<T>(
    Future<T> Function() operation, {
    String? errorMessage,
  }) async {
    try {
      return await operation();
    } on AuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception(errorMessage ?? 'Operation failed: $e');
    }
  }
}