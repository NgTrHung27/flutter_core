import 'package:fpdart/fpdart.dart';
import '../entities/profiling_entity.dart';
import '../failures/profiling_failures.dart';

abstract class ProfilingRepository {
  Future<Either<ProfilingFailure, CpuBenchmarkResult>> runCpuBenchmark(String taskType);
  Future<Either<ProfilingFailure, MemoryBenchmarkResult>> checkMemoryLeaks();
  Future<Either<ProfilingFailure, List<PerformanceMetric>>> collectMetrics();
}
