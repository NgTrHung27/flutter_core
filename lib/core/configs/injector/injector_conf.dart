import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../api/api_helper.dart';
import '../../api/api_interceptor.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../blocs/translate/translate_bloc.dart';
import '../../cache/hive_local_storage.dart';
import '../../cache/secure_local_storage.dart';
import '../../network/network_checker.dart';
import '../../network/ssl_pinning_service.dart';
import '../../../features/auth/di/auth_depedency.dart';
import '../../../features/home/di/home_dependency.dart';
import '../../../features/profiling/di/profiling_dependency.dart';
import '../../../features/isolate_demo/data/datasources/isolate_remote_data_source.dart';
import '../../../features/isolate_demo/data/repositories/isolate_repository_impl.dart';
import '../../../features/isolate_demo/domain/repositories/isolate_repository.dart';
import '../../../features/isolate_demo/domain/usecases/get_heavy_payload_usecase.dart';
import '../../../features/isolate_demo/presentation/bloc/isolate_bloc.dart';
import 'injector.dart';

final getIt = GetIt.I;

Future<void> configureDepedencies() async {
  // Feature dependencies
  AuthDepedency.init();
  HomeDependency.init();
  ProfilingDependency.init();

  // Core dependencies
  getIt.registerLazySingleton(() => ThemeBloc());
  getIt.registerLazySingleton(() => TranslateBloc());
  getIt.registerLazySingleton(() => AppRouteConf());
  getIt.registerLazySingleton(() => ApiInterceptor());

  // Load SSL pins từ Firebase, sau đó khởi tạo Dio với SSL Pinning
  final sslPins = await loadSslPins();
  final dio = buildDioWithSslPinning(sslPins);
  dio.interceptors.add(getIt<ApiInterceptor>());

  getIt.registerLazySingleton<Dio>(() => dio);
  getIt.registerLazySingleton(() => ApiHelper(getIt<Dio>()));
  getIt.registerLazySingleton(
    () => SecureLocalStorage(getIt<FlutterSecureStorage>()),
  );
  getIt.registerLazySingleton(() => HiveLocalStorage());
  getIt.registerLazySingleton(
    () => NetworkInfo(getIt<InternetConnectionChecker>()),
  );
  getIt.registerLazySingleton(() => InternetConnectionChecker.createInstance());
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  );

  // Isolate Demo dependencies
  getIt.registerLazySingleton<IsolateRemoteDataSource>(
    () => IsolateRemoteDataSourceImpl(getIt<ApiHelper>()),
  );
  getIt.registerLazySingleton<IsolateRepository>(
    () => IsolateRepositoryImpl(
      remoteDataSource: getIt<IsolateRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetHeavyPayloadUseCase(getIt<IsolateRepository>()),
  );
  getIt.registerFactory(
    () => IsolateBloc(getHeavyPayloadUseCase: getIt<GetHeavyPayloadUseCase>()),
  );
}
