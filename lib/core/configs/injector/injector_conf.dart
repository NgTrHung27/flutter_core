import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../api/api_helper.dart';
import '../../api/api_interceptor.dart';
import '../../api/api_url.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../blocs/translate/translate_bloc.dart';
import '../../cache/hive_local_storage.dart';
import '../../cache/secure_local_storage.dart';
import '../../network/network_checker.dart';
import '../../../features/auth/di/auth_depedency.dart';
import 'injector.dart';

final getIt = GetIt.I;

void configureDepedencies() {
  AuthDepedency.init();
  // ProductDependency.init();

  getIt.registerLazySingleton(() => ThemeBloc());

  getIt.registerLazySingleton(() => TranslateBloc());

  getIt.registerLazySingleton(() => AppRouteConf());

  getIt.registerLazySingleton(() => ApiHelper(getIt<Dio>()));

  getIt.registerLazySingleton(
    () => Dio(
      BaseOptions(
        baseUrl: ApiUrl.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    )..interceptors.add(getIt<ApiInterceptor>()),
  );

  getIt.registerLazySingleton(() => ApiInterceptor());

  getIt.registerLazySingleton(
    () => SecureLocalStorage(getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton(() => HiveLocalStorage());

  getIt.registerLazySingleton(
    () => NetworkInfo(getIt<InternetConnectionChecker>()),
  );

  getIt.registerLazySingleton(() => InternetConnectionChecker.createInstance());

  getIt.registerLazySingleton(() => const FlutterSecureStorage());
}
