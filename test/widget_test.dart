// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:baru/main.dart';
import 'package:baru/splashscreen.dart';

void main() {
  testWidgets('App starts with SplashScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MainApp());

    // Verify that SplashScreen is shown first.
    expect(find.byType(SplashScreen), findsOneWidget);

    // You can also add delays to simulate the splash screen duration and test navigation
    // For example, wait for 3 seconds
    await tester.pump(const Duration(seconds: 3));

    // After the splash screen, it should navigate away.
    // Here you would test for the login page, for example.
    // expect(find.byType(PageLogin), findsOneWidget);
  });
}
