import '../../../core/configs/injector/injector_conf.dart';
import '../data/datasources/home_local_datasource.dart';
import '../data/repositories/home_repository_impl.dart';
import '../domain/repositories/home_repository.dart';
import '../domain/usecases/home_usecases.dart';
import '../presentation/bloc/home_bloc.dart';

class HomeDependency {
  HomeDependency._();

  static void init() {
    // Data Sources
    getIt.registerLazySingleton<HomeLocalDataSource>(
      () => HomeLocalDataSourceImpl(),
    );

    // Repository
    getIt.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(localDataSource: getIt<HomeLocalDataSource>()),
    );

    // Use Cases
    getIt.registerLazySingleton(
      () => GetHomeDataUseCase(getIt<HomeRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetAvailableDemosUseCase(getIt<HomeRepository>()),
    );
    getIt.registerLazySingleton(
      () => LogDemoAccessUseCase(getIt<HomeRepository>()),
    );

    // BLoC
    getIt.registerFactory(
      () => HomeBloc(
        getHomeDataUseCase: getIt<GetHomeDataUseCase>(),
        getAvailableDemosUseCase: getIt<GetAvailableDemosUseCase>(),
        logDemoAccessUseCase: getIt<LogDemoAccessUseCase>(),
      ),
    );
  }
}
