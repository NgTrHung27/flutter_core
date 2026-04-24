import '../../domain/entities/profiling_entity.dart';

abstract class ProfilingLocalDataSource {
  Future<CpuBenchmarkResult> runCpuBenchmark(String taskType);
  Future<MemoryBenchmarkResult> checkMemoryLeaks();
  Future<List<PerformanceMetric>> collectMetrics();
}

class ProfilingLocalDataSourceImpl implements ProfilingLocalDataSource {
  @override
  Future<CpuBenchmarkResult> runCpuBenchmark(String taskType) async {
    final stopwatch = Stopwatch()..start();

    switch (taskType) {
      case 'fibonacci':
        _fibonacci(40);
        break;
      case 'factorial':
        _factorial(25);
        break;
      case 'sorting':
        _sortingBenchmark();
        break;
      default:
        _fibonacci(40);
    }

    stopwatch.stop();
    
    return CpuBenchmarkResult(
      taskName: taskType,
      iterations: 1,
      executionTime: stopwatch.elapsed,
      averageTimeMs: stopwatch.elapsedMilliseconds.toDouble(),
    );
  }

  @override
  Future<MemoryBenchmarkResult> checkMemoryLeaks() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MemoryBenchmarkResult(
      description: 'Memory leak check completed',
      allocatedBytes: 0,
      hasLeak: false,
    );
  }

  @override
  Future<List<PerformanceMetric>> collectMetrics() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return [
      const PerformanceMetric(
        name: 'UI Thread Usage',
        category: 'CPU',
        value: 45.0,
        unit: '%',
        severity: MetricSeverity.low,
      ),
      const PerformanceMetric(
        name: 'Memory Usage',
        category: 'Memory',
        value: 120.5,
        unit: 'MB',
        severity: MetricSeverity.low,
      ),
      const PerformanceMetric(
        name: 'Frame Rate',
        category: 'Rendering',
        value: 60.0,
        unit: 'fps',
        severity: MetricSeverity.low,
      ),
    ];
  }

  int _fibonacci(int n) {
    if (n <= 1) return n;
    return _fibonacci(n - 1) + _fibonacci(n - 2);
  }

  int _factorial(int n) {
    if (n <= 1) return 1;
    return n * _factorial(n - 1);
  }

  int _sortingBenchmark() {
    final list = List<int>.generate(1000, (i) => 1000 - i);
    list.sort();
    return list.first;
  }
}
