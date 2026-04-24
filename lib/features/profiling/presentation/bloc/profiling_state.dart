import 'package:equatable/equatable.dart';
import '../../domain/entities/profiling_entity.dart';

abstract class ProfilingState extends Equatable {
  const ProfilingState();

  @override
  List<Object?> get props => [];
}

class ProfilingInitial extends ProfilingState {}

class ProfilingLoading extends ProfilingState {
  final String? message;

  const ProfilingLoading([this.message]);

  @override
  List<Object?> get props => [message];
}

class ProfilingLoaded extends ProfilingState {
  final CpuBenchmarkResult? cpuResult;
  final MemoryBenchmarkResult? memoryResult;
  final List<PerformanceMetric> metrics;
  final DateTime timestamp;

  const ProfilingLoaded({
    this.cpuResult,
    this.memoryResult,
    this.metrics = const [],
    required this.timestamp,
  });

  @override
  List<Object?> get props => [cpuResult, memoryResult, metrics, timestamp];

  ProfilingLoaded copyWith({
    CpuBenchmarkResult? cpuResult,
    MemoryBenchmarkResult? memoryResult,
    List<PerformanceMetric>? metrics,
    DateTime? timestamp,
  }) {
    return ProfilingLoaded(
      cpuResult: cpuResult ?? this.cpuResult,
      memoryResult: memoryResult ?? this.memoryResult,
      metrics: metrics ?? this.metrics,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class ProfilingError extends ProfilingState {
  final String message;

  const ProfilingError(this.message);

  @override
  List<Object?> get props => [message];
}
