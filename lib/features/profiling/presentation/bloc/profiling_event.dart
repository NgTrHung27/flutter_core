import 'package:equatable/equatable.dart';

abstract class ProfilingEvent extends Equatable {
  const ProfilingEvent();

  @override
  List<Object?> get props => [];
}

class RunCpuBenchmarkEvent extends ProfilingEvent {
  final String taskType;

  const RunCpuBenchmarkEvent({this.taskType = 'fibonacci'});

  @override
  List<Object?> get props => [taskType];
}

class CheckMemoryLeaksEvent extends ProfilingEvent {}

class CollectMetricsEvent extends ProfilingEvent {}

class ResetProfilingEvent extends ProfilingEvent {}
