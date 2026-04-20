import 'package:flutter_core/features/auth/domain/usecases/usecase_params.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void setupTestBundle() {
  setUpAll(() {
    // Đăng ký một bản sao rỗng/mặc định
    registerFallbackValue(LoginParams(email: '', password: ''));
  });
}
