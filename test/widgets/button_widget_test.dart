import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import class từ project flutter_core của bạn
import 'package:flutter_core/widgets/button_widget.dart';

void main() {
  // Dữ liệu giả dùng chung
  const tButtonText = 'Đăng Nhập';

  // -------------------------------------------------------------------
  // CÁC KỊCH BẢN TEST CHO BUTTON WIDGET
  // -------------------------------------------------------------------
  group('ButtonWidget', () {
    // CASE 1: RENDER ĐÚNG UI
    testWidgets('Nên hiển thị đúng text được truyền vào', (
      WidgetTester tester,
    ) async {
      // 1. ARRANGE & ACT: Bơm Widget vào màn hình test
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButtonWidget(
              label:
                  tButtonText, // Sửa lại tên tham số nếu bạn dùng 'title' hay 'label'
              callback: () {},
            ),
          ),
        ),
      );

      // 2. ASSERT: Tìm xem trên màn hình có dòng text kia không
      final textFinder = find.text(tButtonText);
      expect(
        textFinder,
        findsOneWidget,
      ); // Quả quyết là chỉ tìm thấy đúng 1 cái
    });

    // CASE 2: TƯƠNG TÁC (USER INTERACTION)
    testWidgets('Nên kích hoạt hàm onPressed khi user tap vào nút', (
      WidgetTester tester,
    ) async {
      // 1. ARRANGE: Tạo một biến cờ để theo dõi xem nút có bị bấm không
      bool isTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButtonWidget(
              label: 'Submit',
              callback: () {
                isTapped = true; // Chuyển cờ thành true nếu bị bấm
              },
            ),
          ),
        ),
      );

      // 2. ACT: Giả lập ngón tay bấm vào nút
      final buttonFinder = find.byType(AppButtonWidget);
      await tester.tap(buttonFinder);

      // Bắt buộc phải có dòng này để đợi Flutter chạy xong các Animation (như hiệu ứng gợn sóng)
      await tester.pumpAndSettle();

      // 3. ASSERT: Kiểm tra biến cờ đã đổi trạng thái chưa
      expect(isTapped, isTrue);
    });

    // CASE 3: TRẠNG THÁI DISABLE (TÙY CHỌN)
    testWidgets('Không kích hoạt hàm onPressed khi truyền null (Disable)', (
      WidgetTester tester,
    ) async {
      // Nếu ButtonWidget của bạn có xử lý disable khi onPressed == null
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButtonWidget(label: 'Disabled Button', callback: null),
          ),
        ),
      );

      final buttonFinder = find.byType(AppButtonWidget);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Test pass nếu tap vào nút disable mà không bị crash hay văng lỗi
      expect(find.text('Disabled Button'), findsOneWidget);
    });
  });
}
