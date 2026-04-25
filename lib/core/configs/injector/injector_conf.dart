import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_core/core/utils/logger.dart';
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
import '../../network/interceptors/ssl_pinning_interceptor.dart';
import '../../network/network_checker.dart';
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

// CHÚ Ý: Đổi thành Future<void> và thêm async
Future<void> configureDepedencies() async {
  AuthDepedency.init();
  HomeDependency.init();
  ProfilingDependency.init();

  // ==========================================
  // LOGIC LẤY FINGERPRINT ĐỘNG TỪ FIREBASE
  // ==========================================
  List<String> dynamicPins = [];

  // Đây là mã Root CA của Let's Encrypt (ISRG Root X1) - Sống đến năm 2035.
  // Dùng làm backup tuyệt đối an toàn nếu Firebase lỗi.
  const String rootCABackup =
      "96:BC:EC:06:26:59:76:F2:27:D1:F3:D9:D6:EB:8D:D8:1A:E5:5D:5C:30:D7:93:18:25:01:83:2B:A3:16:B3:19";

  try {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(
          hours: 1,
        ), // Tránh bị Firebase block do gọi quá nhiều
      ),
    );
    await remoteConfig.fetchAndActivate();

    // Trên Firebase, bạn tạo key 'ssl_pins' và value là string JSON: ["MÃ_1", "MÃ_2"]
    String pinsJson = remoteConfig.getString('ssl_pins');
    if (pinsJson.isNotEmpty) {
      List<dynamic> parsedList = jsonDecode(pinsJson);
      dynamicPins = parsedList.map((e) => e.toString()).toList();
    } else {
      dynamicPins = [rootCABackup];
    }
  } catch (e) {
    logger.e(
      "⚠️ Lỗi tải Firebase Remote Config, sử dụng mã Root CA mặc định: $e",
    );
    dynamicPins = [rootCABackup];
  }

  // ==========================================
  // ĐĂNG KÝ DEPENDENCIES
  // ==========================================

  getIt.registerLazySingleton(() => ThemeBloc());
  getIt.registerLazySingleton(() => TranslateBloc());
  getIt.registerLazySingleton(() => AppRouteConf());

  getIt.registerLazySingleton(() => ApiInterceptor());

  // Đăng ký SslPinningInterceptor và TRUYỀN DANH SÁCH MÃ VÀO
  getIt.registerLazySingleton(
    () => SslPinningInterceptor(allowedFingerprints: dynamicPins),
  );

  getIt.registerLazySingleton(
    () =>
        Dio(
            BaseOptions(
              baseUrl: ApiUrl.apiProduction,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          )
          ..interceptors.add(getIt<ApiInterceptor>())
          ..interceptors.add(
            getIt<SslPinningInterceptor>(),
          ), // Lắp SslPinning vào Dio
  );

  getIt.registerLazySingleton(() => ApiHelper(getIt<Dio>()));

  getIt.registerLazySingleton(
    () => SecureLocalStorage(getIt<FlutterSecureStorage>()),
  );
  getIt.registerLazySingleton(() => HiveLocalStorage());
  getIt.registerLazySingleton(
    () => NetworkInfo(getIt<InternetConnectionChecker>()),
  );
  getIt.registerLazySingleton(() => InternetConnectionChecker.createInstance());
  getIt.registerLazySingleton(() => const FlutterSecureStorage());

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
