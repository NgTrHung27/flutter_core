// File: testing/mocks/repository_mocks.dart
import 'package:mocktail/mocktail.dart';
import 'package:flutter_core/features/auth/domain/repositories/auth_repository.dart';

// 1. Tạo một class Mock mượn xác (implements) từ Repository thật
class MockAuthRepository extends Mock implements AuthRepository {}

// Bạn có thể tạo thêm nhiều Mock khác ở đây...
// class MockSessionRepository extends Mock implements SessionRepository {}
