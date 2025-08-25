import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:k53app/src/core/utils/accessibility_utils.dart';

void main() {
  group('AccessibilityUtils', () {
    testWidgets('setupAccessibility should initialize semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              AccessibilityUtils.setupAccessibility(context, 'TestScreen');
              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );

      // Verify that semantics are initialized
      expect(tester.binding.hasScheduledFrame, isTrue);
    });

    testWidgets('focusNext should move focus correctly', (WidgetTester tester) async {
      final focusNode1 = FocusNode();
      final focusNode2 = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(focusNode: focusNode1),
                TextField(focusNode: focusNode2),
              ],
            ),
          ),
        ),
      );

      // Initially focus on first node
      focusNode1.requestFocus();
      await tester.pump();

      expect(focusNode1.hasFocus, isTrue);
      expect(focusNode2.hasFocus, isFalse);

      // Move focus to next node
      AccessibilityUtils.focusNext(tester.element(find.byType(TextField).first), focusNode1, focusNode2);
      await tester.pump();

      expect(focusNode1.hasFocus, isFalse);
      expect(focusNode2.hasFocus, isTrue);
    });

    test('getKeyboardShortcuts should return correct shortcuts', () {
      final shortcuts = AccessibilityUtils.getKeyboardShortcuts();
      
      expect(shortcuts.length, greaterThan(0));
      expect(shortcuts.containsKey(LogicalKeySet(LogicalKeyboardKey.enter)), isTrue);
      expect(shortcuts.containsKey(LogicalKeySet(LogicalKeyboardKey.tab)), isTrue);
    });

    test('getQuestionSemantics should generate correct semantics', () {
      const question = 'What does this sign mean?';
      final options = ['Stop', 'Yield', 'Go'];

      final semantics = AccessibilityUtils.getQuestionSemantics(question, options);
      
      expect(semantics, contains(question));
      expect(semantics, contains('Option 1: Stop'));
      expect(semantics, contains('Option 2: Yield'));
      expect(semantics, contains('Option 3: Go'));
    });

    test('getContrastColor should return appropriate contrast color', () {
      // Test with light background
      final lightColor = Colors.white;
      final darkContrast = AccessibilityUtils.getContrastColor(lightColor);
      expect(darkContrast, Colors.black);

      // Test with dark background
      final darkColor = Colors.black;
      final lightContrast = AccessibilityUtils.getContrastColor(darkColor);
      expect(lightContrast, Colors.white);
    });

    testWidgets('getAdaptiveTextSize should respect text scale bounds', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final baseSize = 16.0;
              
              // Test with current context
              final size = AccessibilityUtils.getAdaptiveTextSize(context, baseSize);
              expect(size, greaterThanOrEqualTo(baseSize * 0.8));
              expect(size, lessThanOrEqualTo(baseSize * 1.5));
              
              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );
    });

    test('getButtonSemantics should return correct semantics map', () {
      const label = 'Submit';
      const hint = 'Press to submit form';
      
      final semantics = AccessibilityUtils.getButtonSemantics(
        label: label,
        hint: hint,
        enabled: true,
      );
      
      expect(semantics['semanticsLabel'], label);
      expect(semantics['semanticsHint'], hint);
      expect(semantics['semanticsEnabled'], true);
    });

    test('getAccessibleButtonPadding should return adequate padding', () {
      final padding = AccessibilityUtils.getAccessibleButtonPadding();
      expect(padding.vertical, greaterThanOrEqualTo(16.0));
      expect(padding.horizontal, greaterThanOrEqualTo(24.0));
    });

    test('getMinimumTouchTargetSize should return adequate size', () {
      final size = AccessibilityUtils.getMinimumTouchTargetSize();
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('isAccessibilityModeEnabled should detect accessibility features', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Test with default settings
              final defaultEnabled = AccessibilityUtils.isAccessibilityModeEnabled(context);
              expect(defaultEnabled, isFalse);

              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );
    });
  });
}