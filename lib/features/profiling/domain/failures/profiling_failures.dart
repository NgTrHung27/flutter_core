import 'package:equatable/equatable.dart';

sealed class ProfilingFailure extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfilingComputeFailure extends ProfilingFailure {
  final String? message;
  ProfilingComputeFailure([this.message]);
  @override
  List<Object?> get props => [message];
}

class ProfilingMemoryFailure extends ProfilingFailure {
  final String? message;
  ProfilingMemoryFailure([this.message]);
  @override
  List<Object?> get props => [message];
}
