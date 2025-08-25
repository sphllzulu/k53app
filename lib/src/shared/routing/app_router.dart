import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/study/presentation/screens/study_screen.dart';

class AppRouter {
  static GoRouter router(WidgetRef ref) {
    return GoRouter(
      redirect: (context, state) {
        final authState = ref.read(authProvider).value;
        final isAuthenticated = authState?.session != null;

        final isGoingToAuth = state.matchedLocation.startsWith('/auth');

        if (!isAuthenticated && !isGoingToAuth) {
          return '/auth/login';
        }

        if (isAuthenticated && isGoingToAuth) {
          return '/dashboard';
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
          path: '/',
          redirect: (context, state) => '/dashboard',
        ),
      ],
    );
  }
}