import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppTheme {
  light,
  dark,
  system,
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(AppTheme.system);

  void setTheme(AppTheme theme) {
    state = theme;
  }

  void toggleTheme() {
    state = state == AppTheme.light ? AppTheme.dark : AppTheme.light;
  }
}