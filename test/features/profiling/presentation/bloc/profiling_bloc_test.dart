import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_core/features/profiling/domain/entities/profiling_entity.dart';
import 'package:flutter_core/features/profiling/domain/failures/profiling_failures.dart';
import 'package:flutter_core/features/profiling/domain/usecases/profiling_usecases.dart';
import 'package:flutter_core/features/profiling/presentation/bloc/profiling_bloc.dart';
import 'package:flutter_core/features/profiling/presentation/bloc/profiling_event.dart';
import 'package:flutter_core/features/profiling/presentation/bloc/profiling_state.dart';
import 'package:flutter_core/features/profiling/domain/repositories/profiling_repository.dart';
import 'package:fpdart/fpdart.dart';

class MockProfilingRepository extends Mock implements ProfilingRepository {}

void main() {
  late ProfilingBloc profilingBloc;
  late MockProfilingRepository mockProfilingRepository;

  const testCpuResult = CpuBenchmarkResult(
    taskName: 'fibonacci',
    iterations: 1,
    executionTime: Duration(milliseconds: 500),
    averageTimeMs: 500.0,
  );

  const testMemoryResult = MemoryBenchmarkResult(
    description: 'Memory check',
    allocatedBytes: 1024,
    hasLeak: false,
  );

  final testMetrics = <PerformanceMetric>[
    const PerformanceMetric(
      name: 'CPU Usage',
      category: 'CPU',
      value: 45.0,
      unit: '%',
      severity: MetricSeverity.low,
    ),
  ];

  setUp(() {
    mockProfilingRepository = MockProfilingRepository();
    final runCpuBenchmarkUseCase = RunCpuBenchmarkUseCase(mockProfilingRepository);
    final checkMemoryLeaksUseCase = CheckMemoryLeaksUseCase(mockProfilingRepository);
    final collectMetricsUseCase = CollectMetricsUseCase(mockProfilingRepository);

    profilingBloc = ProfilingBloc(
      runCpuBenchmarkUseCase: runCpuBenchmarkUseCase,
      checkMemoryLeaksUseCase: checkMemoryLeaksUseCase,
      collectMetricsUseCase: collectMetricsUseCase,
    );
  });

  tearDown(() {
    profilingBloc.close();
  });

  group('ProfilingBloc', () {
    test('initial state is ProfilingInitial', () {
      expect(profilingBloc.state, isA<ProfilingInitial>());
    });

    group('RunCpuBenchmarkEvent', () {
      blocTest<ProfilingBloc, ProfilingState>(
        'emits [ProfilingLoading, ProfilingLoaded] when benchmark succeeds',
        build: () {
          when(() => mockProfilingRepository.runCpuBenchmark(any()))
              .thenAnswer((_) async => const Right(testCpuResult));
          return profilingBloc;
        },
        act: (bloc) => bloc.add(const RunCpuBenchmarkEvent(taskType: 'fibonacci')),
        expect: () => [
          isA<ProfilingLoading>(),
          isA<ProfilingLoaded>()
              .having((s) => s.cpuResult, 'cpuResult', testCpuResult),
        ],
        verify: (_) {
          verify(() => mockProfilingRepository.runCpuBenchmark('fibonacci')).called(1);
        },
      );

      blocTest<ProfilingBloc, ProfilingState>(
        'emits [ProfilingLoading, ProfilingError] when benchmark fails',
        build: () {
          when(() => mockProfilingRepository.runCpuBenchmark(any()))
              .thenAnswer((_) async => Left(ProfilingComputeFailure('Compute error')));
          return profilingBloc;
        },
        act: (bloc) => bloc.add(const RunCpuBenchmarkEvent(taskType: 'fibonacci')),
        expect: () => [
          isA<ProfilingLoading>(),
          isA<ProfilingError>()
              .having((s) => s.message, 'message', contains('Compute error')),
        ],
      );

      blocTest<ProfilingBloc, ProfilingState>(
        'updates existing ProfilingLoaded state',
        build: () {
          when(() => mockProfilingRepository.runCpuBenchmark(any()))
              .thenAnswer((_) async => const Right(testCpuResult));
          return profilingBloc;
        },
        seed: () => ProfilingLoaded(
          memoryResult: testMemoryResult,
          metrics: testMetrics,
          timestamp: DateTime.now(),
        ),
        act: (bloc) => bloc.add(const RunCpuBenchmarkEvent(taskType: 'fibonacci')),
        expect: () => [
          isA<ProfilingLoading>(),
          isA<ProfilingLoaded>()
              .having((s) => s.cpuResult, 'cpuResult', testCpuResult)
              .having((s) => s.memoryResult, 'memoryResult', testMemoryResult)
              .having((s) => s.metrics, 'metrics', testMetrics),
        ],
      );
    });

    group('CheckMemoryLeaksEvent', () {
      blocTest<ProfilingBloc, ProfilingState>(
        'emits [ProfilingLoading, ProfilingLoaded] when check succeeds',
        build: () {
          when(() => mockProfilingRepository.checkMemoryLeaks())
              .thenAnswer((_) async => const Right(testMemoryResult));
          return profilingBloc;
        },
        act: (bloc) => bloc.add(CheckMemoryLeaksEvent()),
        expect: () => [
          isA<ProfilingLoading>(),
          isA<ProfilingLoaded>()
              .having((s) => s.memoryResult, 'memoryResult', testMemoryResult),
        ],
        verify: (_) {
          verify(() => mockProfilingRepository.checkMemoryLeaks()).called(1);
        },
      );

      blocTest<ProfilingBloc, ProfilingState>(
        'emits [ProfilingLoading, ProfilingError] when check fails',
        build: () {
          when(() => mockProfilingRepository.checkMemoryLeaks())
              .thenAnswer((_) async => Left(ProfilingMemoryFailure('Memory error')));
          return profilingBloc;
        },
        act: (bloc) => bloc.add(CheckMemoryLeaksEvent()),
        expect: () => [
          isA<ProfilingLoading>(),
          isA<ProfilingError>()
              .having((s) => s.message, 'message', contains('Memory error')),
        ],
      );
    });

    group('CollectMetricsEvent', () {
      blocTest<ProfilingBloc, ProfilingState>(
        'emits [ProfilingLoading, ProfilingLoaded] when metrics collection succeeds',
        build: () {
          when(() => mockProfilingRepository.collectMetrics())
              .thenAnswer((_) async => Right(testMetrics));
          return profilingBloc;
        },
        act: (bloc) => bloc.add(CollectMetricsEvent()),
        expect: () => [
          isA<ProfilingLoading>(),
          isA<ProfilingLoaded>()
              .having((s) => s.metrics, 'metrics', testMetrics),
        ],
        verify: (_) {
          verify(() => mockProfilingRepository.collectMetrics()).called(1);
        },
      );

      blocTest<ProfilingBloc, ProfilingState>(
        'emits [ProfilingLoading, ProfilingError] when metrics collection fails',
        build: () {
          when(() => mockProfilingRepository.collectMetrics())
              .thenAnswer((_) async => Left(ProfilingComputeFailure('Metrics error')));
          return profilingBloc;
        },
        act: (bloc) => bloc.add(CollectMetricsEvent()),
        expect: () => [
          isA<ProfilingLoading>(),
          isA<ProfilingError>()
              .having((s) => s.message, 'message', contains('Metrics error')),
        ],
      );
    });

    group('ResetProfilingEvent', () {
      blocTest<ProfilingBloc, ProfilingState>(
        'emits [ProfilingInitial] when reset is triggered',
        build: () => profilingBloc,
        seed: () => ProfilingLoaded(
          cpuResult: testCpuResult,
          memoryResult: testMemoryResult,
          metrics: testMetrics,
          timestamp: DateTime.now(),
        ),
        act: (bloc) => bloc.add(ResetProfilingEvent()),
        expect: () => [
          isA<ProfilingInitial>(),
        ],
      );
    });
  });
}
