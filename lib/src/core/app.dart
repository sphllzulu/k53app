import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import './app_initializer.dart';
import './services/supabase_service.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../shared/routing/app_router.dart';
import '../core/providers/theme_provider.dart';

class K53App extends ConsumerStatefulWidget {
  const K53App({super.key});

  @override
  ConsumerState<K53App> createState() => _K53AppState();
}

class _K53AppState extends ConsumerState<K53App> {
  @override
  Widget build(BuildContext context) {
    // Watch auth state to rebuild when auth changes
    final authState = ref.watch(authProvider);
    final theme = ref.watch(themeProvider);
    
    // Create router in build method to have access to ref
    final router = AppRouter.router(ref);
    
    // Determine theme mode based on provider
    ThemeMode themeMode;
    switch (theme) {
      case AppTheme.light:
        themeMode = ThemeMode.light;
        break;
      case AppTheme.dark:
        themeMode = ThemeMode.dark;
        break;
      case AppTheme.system:
        themeMode = ThemeMode.system;
        break;
    }

    return MaterialApp.router(
      title: 'K53 Learner\'s License',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            // Dismiss keyboard when tapping outside text fields
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: child,
        );
      },
    );
  }
}