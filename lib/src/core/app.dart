import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import './app_initializer.dart';
import './services/supabase_service.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../shared/routing/app_router.dart';

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
    
    // Create router in build method to have access to ref
    final router = AppRouter.router(ref);

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
      themeMode: ThemeMode.system,
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