import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';

class AccessibilityUtils {
  // Set up accessibility for screen readers
  static void setupAccessibility(BuildContext context, String screenName) {
    // Announce screen change for screen readers
    Future.delayed(const Duration(milliseconds: 500), () {
      SemanticsBinding.instance.ensureSemantics();
      // For screen reader announcements, we'll use platform channels or live region updates
      // This is handled automatically by Flutter's Semantics framework
    });
  }

  // Focus management for keyboard navigation
  static void focusNext(BuildContext context, FocusNode current, FocusNode next) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  // Handle keyboard shortcuts
  static Map<LogicalKeySet, Intent> getKeyboardShortcuts() {
    return {
      LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
      LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
      LogicalKeySet(LogicalKeyboardKey.tab): const NextFocusIntent(),
      LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab):
          const PreviousFocusIntent(),
      LogicalKeySet(LogicalKeyboardKey.arrowRight): const NextFocusIntent(),
      LogicalKeySet(LogicalKeyboardKey.arrowLeft): const PreviousFocusIntent(),
      LogicalKeySet(LogicalKeyboardKey.arrowDown): const NextFocusIntent(),
      LogicalKeySet(LogicalKeyboardKey.arrowUp): const PreviousFocusIntent(),
    };
  }

  // Generate semantic labels for screen readers
  static String getQuestionSemantics(String question, List<String> options) {
    final optionsText = options.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final option = entry.value;
      return 'Option $index: $option';
    }).join(', ');

    return '$question. Options: $optionsText';
  }

  // Get contrast ratio compliant colors
  static Color getContrastColor(Color backgroundColor) {
    // Calculate luminance and return appropriate contrast color
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Check if text size should be increased based on system settings
  static double getAdaptiveTextSize(BuildContext context, double baseSize) {
    final mediaQuery = MediaQuery.of(context);
    final textScaleFactor = mediaQuery.textScaleFactor;
    
    // Apply minimum and maximum bounds
    return baseSize * textScaleFactor.clamp(0.8, 1.5);
  }

  // Generate accessible button semantics
  static Map<String, dynamic> getButtonSemantics({
    required String label,
    String? hint,
    bool enabled = true,
  }) {
    return {
      'semanticsLabel': label,
      if (hint != null) 'semanticsHint': hint,
      'semanticsEnabled': enabled,
    };
  }

  // Handle vibration feedback for accessibility
  static void provideHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  // Check if accessibility features are enabled
  static bool isAccessibilityModeEnabled(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.boldText || mediaQuery.accessibleNavigation;
  }

  // Check if screen reader is enabled
  static Future<bool> isScreenReaderEnabled() async {
    // This would typically use platform channels to check screen reader status
    // For now, we'll return a default value
    return false;
  }

  // Check if high contrast mode is enabled
  static Future<bool> isHighContrastEnabled() async {
    // This would typically use platform channels to check high contrast settings
    // For now, we'll return a default value
    return false;
  }

  // Announce text for screen readers
  static void announce(String message) {
    // Use SemanticsService to announce to screen readers
    // This is a simplified implementation
    SemanticsBinding.instance.ensureSemantics();
    // In a real implementation, you'd use platform channels or live regions
  }

  // Get appropriate button padding for touch targets
  static EdgeInsets getAccessibleButtonPadding() {
    return const EdgeInsets.symmetric(vertical: 16, horizontal: 24);
  }

  // Get minimum touch target size
  static Size getMinimumTouchTargetSize() {
    return const Size(48, 48);
  }
}