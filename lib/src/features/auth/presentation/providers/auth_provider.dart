import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

final authProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return SupabaseService.auth.currentUser;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return SupabaseService.isAuthenticated;
});

final authLoadingProvider = StateProvider<bool>((ref) => false);

final authErrorProvider = StateProvider<String?>((ref) => null);