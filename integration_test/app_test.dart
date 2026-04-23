import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Import file main của project để khởi động app
import 'package:flutter_core/main.dart' as app;

void main() {
  // 1. Khởi tạo môi trường Integration Test (Bắt buộc phải có để giao tiếp với máy ảo)
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test: Luồng Đăng Nhập', () {
    testWidgets('Gõ email, mật khẩu và bấm đăng nhập thành công', (
      tester,
    ) async {
      // 2. Khởi động toàn bộ ứng dụng
      app.main();

      // Đợi app render xong khung hình đầu tiên (VD: Đợi hết Splash Screen sang Login Screen)
      await tester.pumpAndSettle();

      // 3. Tìm các Widget trên màn hình
      // Dưới đây giả định tìm theo Type:
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;

      // Tìm ButtonWidget dựa trên text truyền vào (Ví dụ: 'Đăng Nhập')
      final loginButton = find.text('Đăng Nhập');

      // 4. Giả lập người dùng gõ phím
      await tester.enterText(emailField, 'test@gmail.com');
      await tester.pumpAndSettle(); // Đợi UI cập nhật hiển thị chữ vừa gõ

      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle(); // Đợi ẩn bàn phím / cập nhật UI

      // 5. Thao tác bấm nút
      await tester.tap(loginButton);

      // 6. Chờ quá trình loading (call API hoặc logic BLoC) và chuyển trang
      // pumpAndSettle sẽ chờ đến khi không còn animation nào diễn ra
      await tester.pumpAndSettle();

      // 7. ASSERT: Quả quyết kết quả
      // Sau khi login xong, app sẽ chuyển hướng. Hãy tìm một widget/text đặc trưng để khẳng định Test Pass.
      expect(find.text('Trang chủ'), findsOneWidget);
    });
  });
}
