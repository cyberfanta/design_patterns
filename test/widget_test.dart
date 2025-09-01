// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:design_patterns/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Design Patterns App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DesignPatternsApp());

    // Wait for animations and async operations to complete
    await tester.pumpAndSettle();

    // Verify that our app shows the correct title.
    expect(
        find.text('Design Patterns - Tower Defense Edition'), findsOneWidget);

    // Verify welcome content is displayed
    expect(find.text('Welcome to Design Patterns Learning Platform'),
        findsOneWidget);

    // Verify that some pattern names are in the sidebar
    expect(find.text('Factory Method'), findsOneWidget);
    expect(find.text('Singleton'), findsOneWidget);

    // Scroll to make sure Observer is visible
    await tester.drag(find
        .byType(ListView)
        .first, const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(find.text('Observer'), findsOneWidget);
  });

  testWidgets('Pattern selection works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DesignPatternsApp());

    // Tap on Factory Method pattern
    await tester.tap(find.text('Factory Method'));
    await tester.pumpAndSettle();

    // Verify that pattern details are shown
    expect(find.text('Creates enemies without specifying exact classes'),
        findsOneWidget);
    expect(find.text('Run Demo'), findsOneWidget);
  });
}