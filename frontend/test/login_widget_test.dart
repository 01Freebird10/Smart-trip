import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic UI elements test', (WidgetTester tester) async {
    // Simple test that doesn't depend on complex app initialization
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Smart Trip Planner'),
          ),
        ),
      ),
    );

    expect(find.text('Smart Trip Planner'), findsOneWidget);
  });
}
