// Basic widget test for RainTech Smart Test App
//
// This test verifies that the app's theme configuration is correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raintech_smart_test/app/theme/app_theme.dart';

void main() {
  testWidgets('App theme has correct primary color', (WidgetTester tester) async {
    // Build a simple widget with the app theme
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: Text('Test'),
          ),
        ),
      ),
    );

    // Verify the theme is applied
    final theme = tester.widget<MaterialApp>(find.byType(MaterialApp)).theme;
    expect(theme?.primaryColor, AppTheme.primaryColor);
  });

  testWidgets('App theme has correct background color', (WidgetTester tester) async {
    // Build a simple widget with the app theme
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: Text('Test'),
          ),
        ),
      ),
    );

    // Verify the theme is applied
    final theme = tester.widget<MaterialApp>(find.byType(MaterialApp)).theme;
    expect(theme?.scaffoldBackgroundColor, AppTheme.backgroundColor);
  });
}
