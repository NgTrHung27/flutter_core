import 'package:fpdart/fpdart.dart';
import '../../domain/entities/profiling_entity.dart';
import '../../domain/failures/profiling_failures.dart';
import '../../domain/repositories/profiling_repository.dart';
import '../datasources/profiling_local_datasource.dart';

class ProfilingRepositoryImpl implements ProfilingRepository {
  final ProfilingLocalDataSource localDataSource;

  ProfilingRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<ProfilingFailure, CpuBenchmarkResult>> runCpuBenchmark(
    String taskType,
  ) async {
    try {
      final result = await localDataSource.runCpuBenchmark(taskType);
      return Right(result);
    } catch (e) {
      return Left(ProfilingComputeFailure(e.toString()));
    }
  }

  @override
  Future<Either<ProfilingFailure, MemoryBenchmarkResult>> checkMemoryLeaks() async {
    try {
      final result = await localDataSource.checkMemoryLeaks();
      return Right(result);
    } catch (e) {
      return Left(ProfilingMemoryFailure(e.toString()));
    }
  }

  @override
  Future<Either<ProfilingFailure, List<PerformanceMetric>>> collectMetrics() async {
    try {
      final result = await localDataSource.collectMetrics();
      return Right(result);
    } catch (e) {
      return Left(ProfilingComputeFailure(e.toString()));
    }
  }
}
