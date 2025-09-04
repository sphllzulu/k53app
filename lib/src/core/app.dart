import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import './app_initializer.dart';
import './services/supabase_service.dart';
import './services/session_persistence_service.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/study/presentation/providers/study_provider.dart';
import '../features/exam/presentation/providers/exam_provider.dart';
import '../shared/routing/app_router.dart';
import '../shared/widgets/session_recovery_dialog.dart';

class K53App extends ConsumerStatefulWidget {
  const K53App({super.key});

  @override
  ConsumerState<K53App> createState() => _K53AppState();
}

class _K53AppState extends ConsumerState<K53App> {
  bool _sessionRecoveryChecked = false;

  @override
  void initState() {
    super.initState();
    _checkForPendingSessions();
  }

  Future<void> _checkForPendingSessions() async {
    // Wait a bit for the app to initialize and check auth state
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Only check for sessions if user is authenticated
    final authState = ref.read(authProvider);
    final isAuthenticated = authState.value?.session != null;
    
    if (!isAuthenticated) {
      if (mounted) {
        setState(() {
          _sessionRecoveryChecked = true;
        });
      }
      return;
    }
    
    // Check for any pending sessions
    final studySession = await SessionPersistenceService.loadStudySession();
    final examSession = await SessionPersistenceService.loadExamSession();
    
    if (mounted) {
      setState(() {
        _sessionRecoveryChecked = true;
      });
      
      // Show recovery dialog only for valid sessions
      if (studySession != null && SessionPersistenceService.isSessionValid(studySession)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showSessionRecoveryDialog(context, studySession, SessionType.study);
          }
        });
      } else if (studySession != null) {
        // Clear expired study session
        SessionPersistenceService.clearStudySession();
      }
      
      if (examSession != null && SessionPersistenceService.isSessionValid(examSession)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showSessionRecoveryDialog(context, examSession, SessionType.exam);
          }
        });
      } else if (examSession != null) {
        // Clear expired exam session
        SessionPersistenceService.clearExamSession();
      }
    }
  }

  void _showSessionRecoveryDialog(BuildContext context, SessionState session, SessionType sessionType) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SessionRecoveryDialog(
        session: session,
        onContinue: () {
          Navigator.of(context).pop();
          _continueSession(session, sessionType);
        },
        onStartNew: () {
          Navigator.of(context).pop();
          _startNewSession(sessionType);
        },
      ),
    );
  }

  void _continueSession(SessionState session, SessionType sessionType) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = GoRouter.of(context);
      
      if (sessionType == SessionType.study) {
        ref.read(studyProvider.notifier).loadSessionState(session);
        router.go('/study');
      } else if (sessionType == SessionType.exam) {
        ref.read(examProvider.notifier).loadSessionState(session);
        router.go('/exam');
      }
    });
  }

  void _startNewSession(SessionType sessionType) {
    if (sessionType == SessionType.study) {
      SessionPersistenceService.clearStudySession();
    } else if (sessionType == SessionType.exam) {
      SessionPersistenceService.clearExamSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state to rebuild when auth changes
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.value?.session != null;
    
    // Check for sessions when authentication state changes from unauthenticated to authenticated
    if (isAuthenticated && !_sessionRecoveryChecked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForPendingSessions();
      });
    }
    
    // Reset session recovery check when user logs out
    if (!isAuthenticated && _sessionRecoveryChecked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _sessionRecoveryChecked = false;
          });
        }
      });
    }
    
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