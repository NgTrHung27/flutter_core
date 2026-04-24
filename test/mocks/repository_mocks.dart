// File: testing/mocks/repository_mocks.dart
import 'package:mocktail/mocktail.dart';
import 'package:flutter_core/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_core/features/isolate_demo/domain/repositories/isolate_repository.dart';
import 'package:flutter_core/features/home/domain/repositories/home_repository.dart';
import 'package:flutter_core/features/profiling/domain/repositories/profiling_repository.dart';

// Auth Repository Mock
class MockAuthRepository extends Mock implements AuthRepository {}

// Isolate Repository Mock
class MockIsolateRepository extends Mock implements IsolateRepository {}

// Home Repository Mock
class MockHomeRepository extends Mock implements HomeRepository {}

// Profiling Repository Mock
class MockProfilingRepository extends Mock implements ProfilingRepository {}

// Register fallback values for mocktail
void registerFallbackValues() {
  registerFallbackValue(<String>[]);
}
