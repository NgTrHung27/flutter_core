import 'package:fpdart/fpdart.dart';
import '../entities/profiling_entity.dart';
import '../failures/profiling_failures.dart';
import '../repositories/profiling_repository.dart';

class RunCpuBenchmarkUseCase {
  final ProfilingRepository repository;

  RunCpuBenchmarkUseCase(this.repository);

  Future<Either<ProfilingFailure, CpuBenchmarkResult>> call(String taskType) async {
    return repository.runCpuBenchmark(taskType);
  }
}

class CheckMemoryLeaksUseCase {
  final ProfilingRepository repository;

  CheckMemoryLeaksUseCase(this.repository);

  Future<Either<ProfilingFailure, MemoryBenchmarkResult>> call() async {
    return repository.checkMemoryLeaks();
  }
}

class CollectMetricsUseCase {
  final ProfilingRepository repository;

  CollectMetricsUseCase(this.repository);

  Future<Either<ProfilingFailure, List<PerformanceMetric>>> call() async {
    return repository.collectMetrics();
  }
}
