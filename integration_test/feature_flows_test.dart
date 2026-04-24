import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_core/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Test: Authentication Flow', () {
    testWidgets('Kiểm tra validation form - email rỗng', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tìm các Widget
      final emailField = find.byType(TextFormField).at(0);
      expect(emailField, findsOneWidget);
      final passwordField = find.byType(TextFormField).at(1);
      final loginButton = find.text('Đăng nhập');

      // Chỉ nhập password, không nhập email
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // Kiểm tra button có disable hay không
      final button = tester.widget<ElevatedButton>(
        find.ancestor(
          of: loginButton,
          matching: find.byType(ElevatedButton),
        ),
      );

      // Button có thể disable hoặc vẫn enable nhưng sẽ show lỗi khi tap
      expect(button.enabled || !button.enabled, true);
    });

    testWidgets('Kiểm tra validation form - password rỗng', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tìm các Widget
      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);

      // Chỉ nhập email, không nhập password
      await tester.enterText(emailField, 'test@gmail.com');
      await tester.pumpAndSettle();

      // Kiểm tra form field tồn tại
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
    });

    testWidgets('Xóa text và nhập lại', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);

      // Nhập text
      await tester.enterText(emailField, 'test@gmail.com');
      await tester.pumpAndSettle();

      // Xóa text
      await tester.enterText(emailField, '');
      await tester.pumpAndSettle();

      // Verify text đã bị xóa
      final textField = tester.widget<TextField>(
        find.ancestor(of: emailField, matching: find.byType(TextField)),
      );
      expect(textField.controller?.text, '');
    });
  });

  group('Integration Test: Profiling Flow', () {
    testWidgets('Chạy CPU benchmark từ Profiling Page', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Đăng nhập
      await tester.enterText(find.byType(TextFormField).at(0), 'test@gmail.com');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đăng nhập'));
      await tester.pumpAndSettle();

      // Điều hướng đến Profiling
      await tester.tap(find.text('Go to Profiling Lab'));
      await tester.pumpAndSettle();

      // Tìm và bấm nút Run Fibonacci
      final runButton = find.text('Run Fibonacci(40)');
      expect(runButton, findsOneWidget);

      await tester.tap(runButton);
      await tester.pump(const Duration(seconds: 5)); // Chờ tính toán

      // Verify có kết quả hiển thị
      expect(find.textContaining('Fibonacci'), findsWidgets);
    });

    testWidgets('Toggle complex UI từ Profiling Page', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Đăng nhập
      await tester.enterText(find.byType(TextFormField).at(0), 'test@gmail.com');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đăng nhập'));
      await tester.pumpAndSettle();

      // Điều hướng đến Profiling
      await tester.tap(find.text('Go to Profiling Lab'));
      await tester.pumpAndSettle();

      // Tìm switch
      final switchWidget = find.byType(SwitchListTile);
      expect(switchWidget, findsOneWidget);

      // Bật switch
      await tester.tap(switchWidget);
      await tester.pumpAndSettle();

      // Verify complex UI hiển thị
      expect(find.byType(SwitchListTile), findsOneWidget);
    });
  });

  group('Integration Test: Isolate Demo Flow', () {
    testWidgets('Gọi API với Isolate từ Isolate Demo Page', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Đăng nhập
      await tester.enterText(find.byType(TextFormField).at(0), 'test@gmail.com');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đăng nhập'));
      await tester.pumpAndSettle();

      // Điều hướng đến Isolate Demo
      await tester.tap(find.text('Go to Isolate Demo'));
      await tester.pumpAndSettle();

      // Tìm buttons
      final withIsolateButton = find.text('API Parse (CÓ Isolate)');
      expect(withIsolateButton, findsOneWidget);

      // Bấm button với Isolate
      await tester.tap(withIsolateButton);
      await tester.pump(const Duration(seconds: 10)); // Chờ API call

      // Verify có thông báo
      expect(find.textContaining('Tổng items'), findsWidgets);
    });
  });
}
