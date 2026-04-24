import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/profiling_usecases.dart';
import 'profiling_event.dart';
import 'profiling_state.dart';

class ProfilingBloc extends Bloc<ProfilingEvent, ProfilingState> {
  final RunCpuBenchmarkUseCase runCpuBenchmarkUseCase;
  final CheckMemoryLeaksUseCase checkMemoryLeaksUseCase;
  final CollectMetricsUseCase collectMetricsUseCase;

  ProfilingBloc({
    required this.runCpuBenchmarkUseCase,
    required this.checkMemoryLeaksUseCase,
    required this.collectMetricsUseCase,
  }) : super(ProfilingInitial()) {
    on<RunCpuBenchmarkEvent>(_onRunCpuBenchmark);
    on<CheckMemoryLeaksEvent>(_onCheckMemoryLeaks);
    on<CollectMetricsEvent>(_onCollectMetrics);
    on<ResetProfilingEvent>(_onReset);
  }

  Future<void> _onRunCpuBenchmark(
    RunCpuBenchmarkEvent event,
    Emitter<ProfilingState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfilingLoaded) {
      emit(ProfilingLoading('Running CPU benchmark...'));
    } else {
      emit(const ProfilingLoading('Running CPU benchmark...'));
    }

    final result = await runCpuBenchmarkUseCase(event.taskType);

    result.fold(
      (failure) => emit(ProfilingError(failure.toString())),
      (cpuResult) {
        final newState = currentState is ProfilingLoaded
            ? currentState.copyWith(
                cpuResult: cpuResult,
                timestamp: DateTime.now(),
              )
            : ProfilingLoaded(
                cpuResult: cpuResult,
                timestamp: DateTime.now(),
              );
        emit(newState);
      },
    );
  }

  Future<void> _onCheckMemoryLeaks(
    CheckMemoryLeaksEvent event,
    Emitter<ProfilingState> emit,
  ) async {
    final currentState = state;
    emit(const ProfilingLoading('Checking memory leaks...'));

    final result = await checkMemoryLeaksUseCase();

    result.fold(
      (failure) => emit(ProfilingError(failure.toString())),
      (memoryResult) {
        final newState = currentState is ProfilingLoaded
            ? currentState.copyWith(
                memoryResult: memoryResult,
                timestamp: DateTime.now(),
              )
            : ProfilingLoaded(
                memoryResult: memoryResult,
                timestamp: DateTime.now(),
              );
        emit(newState);
      },
    );
  }

  Future<void> _onCollectMetrics(
    CollectMetricsEvent event,
    Emitter<ProfilingState> emit,
  ) async {
    final currentState = state;
    emit(const ProfilingLoading('Collecting metrics...'));

    final result = await collectMetricsUseCase();

    result.fold(
      (failure) => emit(ProfilingError(failure.toString())),
      (metrics) {
        final newState = currentState is ProfilingLoaded
            ? currentState.copyWith(
                metrics: metrics,
                timestamp: DateTime.now(),
              )
            : ProfilingLoaded(
                metrics: metrics,
                timestamp: DateTime.now(),
              );
        emit(newState);
      },
    );
  }

  void _onReset(
    ResetProfilingEvent event,
    Emitter<ProfilingState> emit,
  ) {
    emit(ProfilingInitial());
  }
}
