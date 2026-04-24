import '../../../core/configs/injector/injector_conf.dart';
import '../data/datasources/profiling_local_datasource.dart';
import '../data/repositories/profiling_repository_impl.dart';
import '../domain/repositories/profiling_repository.dart';
import '../domain/usecases/profiling_usecases.dart';
import '../presentation/bloc/profiling_bloc.dart';

class ProfilingDependency {
  ProfilingDependency._();

  static void init() {
    // Data Sources
    getIt.registerLazySingleton<ProfilingLocalDataSource>(
      () => ProfilingLocalDataSourceImpl(),
    );

    // Repository
    getIt.registerLazySingleton<ProfilingRepository>(
      () => ProfilingRepositoryImpl(
        localDataSource: getIt<ProfilingLocalDataSource>(),
      ),
    );

    // Use Cases
    getIt.registerLazySingleton(
      () => RunCpuBenchmarkUseCase(getIt<ProfilingRepository>()),
    );
    getIt.registerLazySingleton(
      () => CheckMemoryLeaksUseCase(getIt<ProfilingRepository>()),
    );
    getIt.registerLazySingleton(
      () => CollectMetricsUseCase(getIt<ProfilingRepository>()),
    );

    // BLoC
    getIt.registerFactory(
      () => ProfilingBloc(
        runCpuBenchmarkUseCase: getIt<RunCpuBenchmarkUseCase>(),
        checkMemoryLeaksUseCase: getIt<CheckMemoryLeaksUseCase>(),
        collectMetricsUseCase: getIt<CollectMetricsUseCase>(),
      ),
    );
  }
}
