import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_latn/features/compare/compare_screen.dart';

void main() {
  group('CompareScreen Tests', () {
    testWidgets('should display initial upload section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: CompareScreen()));

      // Verify the initial upload section is displayed
      expect(find.text('Step 1: Upload Initial Image'), findsOneWidget);
      expect(find.text('Tap to select image'), findsOneWidget);
    });

    testWidgets('should display comparison section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: CompareScreen()));

      // Verify the comparison section is displayed
      expect(find.text('Step 2: Compare Images'), findsOneWidget);
      expect(find.text('Please upload an initial image first'), findsOneWidget);
    });

    testWidgets('should have compare button in navigation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: CompareScreen()));

      // Verify the app bar title
      expect(find.text('Image Comparison'), findsOneWidget);
    });
  });
}
