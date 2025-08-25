import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:k53app/src/features/accessibility_test/presentation/screens/accessibility_test_screen.dart';

void main() {
  group('AccessibilityTestScreen', () {
    testWidgets('should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibilityTestScreen(),
        ),
      );

      // Verify the screen title is present
      expect(find.text('Accessibility & Performance Tests'), findsOneWidget);
      
      // Verify the status section is present
      expect(find.text('Current Accessibility Status'), findsOneWidget);
      
      // Verify test suite section is present
      expect(find.text('Test Suite'), findsOneWidget);
      
      // Verify quick actions section is present
      expect(find.text('Quick Actions'), findsOneWidget);
    });

    testWidgets('should display status indicators', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibilityTestScreen(),
        ),
      );

      // Verify status indicators are present
      expect(find.text('Screen Reader'), findsOneWidget);
      expect(find.text('High Contrast'), findsOneWidget);
      expect(find.text('Performance'), findsOneWidget);
    });

    testWidgets('should have font scale test section', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibilityTestScreen(),
        ),
      );

      expect(find.text('Font Scale Test'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('Sample text with scale'), findsOneWidget);
    });

    testWidgets('should have test cards for each test type', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibilityTestScreen(),
        ),
      );

      expect(find.text('Screen Reader'), findsNWidgets(2)); // Status + test card
      expect(find.text('Keyboard Navigation'), findsOneWidget);
      expect(find.text('Contrast Compliance'), findsOneWidget);
      expect(find.text('Performance Benchmark'), findsOneWidget);
    });

    testWidgets('should have quick action chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibilityTestScreen(),
        ),
      );

      expect(find.text('Announce Test'), findsOneWidget);
      expect(find.text('Toggle Contrast'), findsOneWidget);
      expect(find.text('Refresh Status'), findsOneWidget);
    });

    testWidgets('should have performance report button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibilityTestScreen(),
        ),
      );

      expect(find.text('View Performance Report'), findsOneWidget);
    });

    testWidgets('should toggle performance overlay button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibilityTestScreen(),
        ),
      );

      // Find the performance overlay toggle button in app bar
      expect(find.byIcon(Icons.speed_outlined), findsOneWidget);
    });

    testWidgets('should handle font scale slider interaction', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibilityTestScreen(),
        ),
      );

      // Find the slider and verify initial state
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Get initial text
      final initialText = find.textContaining('Sample text with scale');
      expect(initialText, findsOneWidget);

      // Tap and drag the slider
      await tester.tap(slider);
      await tester.pump();

      // The slider should be interactive
      // Note: We can't easily test the visual change without complex setup
    });

    testWidgets('should handle test button interactions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibilityTestScreen(),
        ),
      );

      // Find all test buttons (trailing icons)
      final testButtons = find.byIcon(Icons.play_arrow);
      expect(testButtons, findsNWidgets(4)); // Four test cards

      // Tap the first test button
      await tester.tap(testButtons.first);
      await tester.pump();

      // Should show loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle quick action chip interactions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibilityTestScreen(),
        ),
      );

      // Find action chips
      final announceChip = find.text('Announce Test');
      final toggleChip = find.text('Toggle Contrast');
      final refreshChip = find.text('Refresh Status');

      expect(announceChip, findsOneWidget);
      expect(toggleChip, findsOneWidget);
      expect(refreshChip, findsOneWidget);

      // Tap each chip to ensure they don't crash
      await tester.tap(announceChip);
      await tester.pump();

      await tester.tap(toggleChip);
      await tester.pump();

      await tester.tap(refreshChip);
      await tester.pump();
    });

    testWidgets('should scroll content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibilityTestScreen(),
        ),
      );

      // Verify the screen uses SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Test scrolling (this is a basic smoke test)
      final scrollView = tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
      expect(scrollView.physics, isA<BouncingScrollPhysics>());
    });

    testWidgets('should have proper semantic structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibilityTestScreen(),
        ),
      );

      // Verify key semantic elements are present
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(3)); // Status, font scale, test suite cards
    });
  });
}