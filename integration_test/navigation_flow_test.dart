import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_core/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Test: Navigation Flow', () {
    testWidgets('Đăng nhập thành công và điều hướng đến Home', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Đăng nhập
      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);
      final loginButton = find.text('Đăng nhập');

      await tester.enterText(emailField, 'test@gmail.com');
      await tester.pumpAndSettle();

      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify đã vào Home
      expect(find.text('Home'), findsOneWidget);
      expect(find.textContaining('Welcome'), findsOneWidget);
    });

    testWidgets('Điều hướng từ Home đến Profiling Page', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Đăng nhập trước
      await tester.enterText(find.byType(TextFormField).at(0), 'test@gmail.com');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đăng nhập'));
      await tester.pumpAndSettle();

      // Tìm và bấm nút Profiling Lab
      final profilingButton = find.text('Go to Profiling Lab');
      expect(profilingButton, findsOneWidget);

      await tester.tap(profilingButton);
      await tester.pumpAndSettle();

      // Verify đã vào Profiling Page
      expect(find.text('DevTools Profiling Lab'), findsOneWidget);
    });

    testWidgets('Điều hướng từ Home đến Isolate Demo Page', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Đăng nhập trước
      await tester.enterText(find.byType(TextFormField).at(0), 'test@gmail.com');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đăng nhập'));
      await tester.pumpAndSettle();

      // Tìm và bấm nút Isolate Demo
      final isolateButton = find.text('Go to Isolate Demo');
      expect(isolateButton, findsOneWidget);

      await tester.tap(isolateButton);
      await tester.pumpAndSettle();

      // Verify đã vào Isolate Demo Page
      expect(find.text('Isolate Visual Test'), findsOneWidget);
    });

    testWidgets('Điều hướng từ Home đến RepaintBoundary Demo', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Đăng nhập trước
      await tester.enterText(find.byType(TextFormField).at(0), 'test@gmail.com');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đăng nhập'));
      await tester.pumpAndSettle();

      // Tìm và bấm nút RepaintBoundary Demo
      final repaintButton = find.text('RepaintBoundary Demo');
      expect(repaintButton, findsOneWidget);

      await tester.tap(repaintButton);
      await tester.pumpAndSettle();

      // Verify đã vào RepaintBoundary Page
      expect(find.text('RepaintBoundary Demo Lab'), findsOneWidget);
    });

    testWidgets(' Quay lại Home từ Profiling Page', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Đăng nhập và điều hướng đến Profiling
      await tester.enterText(find.byType(TextFormField).at(0), 'test@gmail.com');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đăng nhập'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Go to Profiling Lab'));
      await tester.pumpAndSettle();

      expect(find.text('DevTools Profiling Lab'), findsOneWidget);

      // Bấm nút back
      final backButton = find.byType(IconButton);
      await tester.tap(backButton.first);
      await tester.pumpAndSettle();

      // Verify đã quay lại Home
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
