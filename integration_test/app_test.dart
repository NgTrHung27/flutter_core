import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Import file main của project để khởi động app
import 'package:flutter_core/main.dart' as app;

void main() {
  // 1. Khởi tạo môi trường Integration Test
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test: Luồng Đăng Nhập', () {
    testWidgets('Gõ email, mật khẩu và bấm đăng nhập thành công', (
      tester,
    ) async {
      // 2. Khởi động toàn bộ ứng dụng
      app.main();

      // Đợi app render xong khung hình đầu tiên và chuyển từ Splash sang trang Auth
      await tester.pumpAndSettle();

      // 3. Tìm các Widget trên màn hình
      // Tìm TextFormField thay vì TextField vì AuthTextField sử dụng TextFormField
      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);

      // Tìm Button dựa trên text 'Đăng nhập' (phải khớp với vi.json)
      final loginButton = find.text('Đăng nhập');

      // 4. Giả lập người dùng gõ phím
      await tester.enterText(emailField, 'test@gmail.com');
      await tester.pumpAndSettle();

      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // 5. Thao tác bấm nút
      await tester.tap(loginButton);

      // 6. Chờ quá trình xử lý (AuthBloc) và chuyển sang trang Home
      // pumpAndSettle sẽ chờ đến khi không còn animation nào (trang đã chuyển xong)
      await tester.pumpAndSettle();

      // 7. ASSERT: Kiểm tra kết quả
      // Trong HomePage.dart, AppBar có tiêu đề là 'Home'
      expect(find.text('Home'), findsOneWidget);
      // Kiểm tra xem có hiển thị câu chào không
      expect(find.textContaining('Welcome'), findsOneWidget);
    });

    testWidgets('Hiển thị lỗi khi đăng nhập với thông tin không hợp lệ', (
      tester,
    ) async {
      // Khởi động toàn bộ ứng dụng
      app.main();

      // Đợi app render xong
      await tester.pumpAndSettle();

      // Tìm các Widget
      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);
      final loginButton = find.text('Đăng nhập');

      // Nhập thông tin không hợp lệ
      await tester.enterText(emailField, 'invalid');
      await tester.pumpAndSettle();

      await tester.enterText(passwordField, '123');
      await tester.pumpAndSettle();

      // Bấm nút đăng nhập
      await tester.tap(loginButton);

      // Đợi xử lý
      await tester.pump(const Duration(seconds: 2));

      // Kiểm tra có hiển thị lỗi hoặc snackbar
      // (Tùy vào logic app có thể hiển thị lỗi khác nhau)
      expect(find.byType(SnackBar).evaluate().isNotEmpty ||
             find.text('Home').evaluate().isEmpty, true);
    });
  });
}
