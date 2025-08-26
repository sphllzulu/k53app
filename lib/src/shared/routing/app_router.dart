import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/accessibility_test/presentation/screens/accessibility_test_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin_auth/presentation/screens/admin_login_screen.dart';
import '../../features/admin_auth/presentation/screens/admin_test_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/study/presentation/screens/study_screen.dart';
import '../../core/services/supabase_service.dart';

class AppRouter {
  static GoRouter router(WidgetRef ref) {
    return GoRouter(
      redirect: (context, state) async {
        final authState = ref.read(authProvider).value;
        final isAuthenticated = authState?.session != null;

        final isGoingToAuth = state.matchedLocation.startsWith('/auth');
        final isGoingToAdmin = state.matchedLocation.startsWith('/admin');
        final isGoingToAdminLogin = state.matchedLocation == '/admin/login';

        print('Router redirect: location=${state.matchedLocation}, authenticated=$isAuthenticated');
        print('isGoingToAuth=$isGoingToAuth, isGoingToAdmin=$isGoingToAdmin, isGoingToAdminLogin=$isGoingToAdminLogin');

        // Redirect to login if not authenticated and trying to access protected routes
        // Allow access to admin login without authentication
        if (!isAuthenticated && !isGoingToAuth && !isGoingToAdminLogin) {
          print('Redirecting to /auth/login (not authenticated)');
          return '/auth/login';
        }

        // Redirect to dashboard if authenticated and trying to access auth routes
        if (isAuthenticated && isGoingToAuth) {
          print('Redirecting to /dashboard (authenticated but going to auth)');
          return '/dashboard';
        }

        // Admin route protection - only protect the dashboard, not login
        if (isAuthenticated && isGoingToAdmin) {
          final isAdminDashboard = state.matchedLocation == '/admin/dashboard';
          
          if (isAdminDashboard) {
            // Check if user has admin role
            try {
              final user = authState!.session!.user;
              final profile = await SupabaseService.client
                  .from('profiles')
                  .select('role')
                  .eq('id', user.id)
                  .single()
                  .catchError((_) => null);

              if (profile == null || (profile['role'] as String?) != 'admin') {
                print('Admin route protection: User is not admin, redirecting to dashboard');
                return '/dashboard'; // Redirect to dashboard if not admin
              }
              print('Admin route protection: User is admin, allowing access');
            } catch (e) {
              print('Admin route protection: Error checking admin role: $e');
              return '/dashboard'; // Redirect on error
            }
          }
        }

        // Special case: if authenticated admin user goes to root, redirect to admin dashboard
        if (isAuthenticated && state.matchedLocation == '/') {
          try {
            final user = authState!.session!.user;
            final profile = await SupabaseService.client
                .from('profiles')
                .select('role')
                .eq('id', user.id)
                .single()
                .catchError((_) => null);

            if (profile != null && (profile['role'] as String?) == 'admin') {
              print('Admin user at root, redirecting to admin dashboard');
              return '/admin/dashboard';
            }
          } catch (e) {
            print('Error checking admin role for root redirect: $e');
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/auth/login',
          name: 'login',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/study',
          name: 'study',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const StudyScreen(),
          ),
        ),
        GoRoute(
          path: '/accessibility-test',
          name: 'accessibility-test',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AccessibilityTestScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/login',
          name: 'admin-login',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminLoginScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/dashboard',
          name: 'admin-dashboard',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminDashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/test',
          name: 'admin-test',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminTestScreen(),
          ),
        ),
        GoRoute(
          path: '/',
          redirect: (context, state) => '/dashboard',
        ),
      ],
    );
  }
}