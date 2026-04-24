import 'package:equatable/equatable.dart';

class ProfilingEntity extends Equatable {
  final CpuBenchmarkResult? cpuResult;
  final MemoryBenchmarkResult? memoryResult;
  final List<PerformanceMetric> metrics;
  final DateTime timestamp;

  const ProfilingEntity({
    this.cpuResult,
    this.memoryResult,
    required this.metrics,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [cpuResult, memoryResult, metrics, timestamp];
}

class CpuBenchmarkResult extends Equatable {
  final String taskName;
  final int iterations;
  final Duration executionTime;
  final double averageTimeMs;

  const CpuBenchmarkResult({
    required this.taskName,
    required this.iterations,
    required this.executionTime,
    required this.averageTimeMs,
  });

  @override
  List<Object?> get props => [taskName, iterations, executionTime, averageTimeMs];
}

class MemoryBenchmarkResult extends Equatable {
  final String description;
  final int allocatedBytes;
  final bool hasLeak;

  const MemoryBenchmarkResult({
    required this.description,
    required this.allocatedBytes,
    required this.hasLeak,
  });

  @override
  List<Object?> get props => [description, allocatedBytes, hasLeak];
}

class PerformanceMetric extends Equatable {
  final String name;
  final String category;
  final double value;
  final String unit;
  final MetricSeverity severity;

  const PerformanceMetric({
    required this.name,
    required this.category,
    required this.value,
    required this.unit,
    required this.severity,
  });

  @override
  List<Object?> get props => [name, category, value, unit, severity];
}

enum MetricSeverity { low, medium, high, critical }
