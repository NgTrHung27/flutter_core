import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/blocs/theme/theme_bloc.dart';
import '../core/blocs/translate/translate_bloc.dart';
import '../core/configs/injector/injector_conf.dart';
import '../core/routes/app_route_conf.dart';
import '../core/routes/app_route_path.dart';
import '../core/themes/app_theme.dart';
import 'auth/presentation/bloc/auth/auth_bloc.dart';

class FlutterCoreApp extends StatelessWidget {
  const FlutterCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = getIt<AppRouteConf>().router;
    return ScreenUtilInit(
      useInheritedMediaQuery: true,
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) => GestureDetector(
        onTap: () => primaryFocus?.unfocus(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<ThemeBloc>()),
            BlocProvider(create: (_) => getIt<TranslateBloc>()),
            BlocProvider(
              create: (_) =>
                  getIt<AuthBloc>()..add(AuthCheckSignInStatusEvent()),
            ),
          ],
          child: BlocListener<AuthBloc, AuthState>(
            listenWhen: (_, current) =>
                current is AuthCheckSignInStatusSuccessState,
            listener: (_, state) {
              if (state is AuthCheckSignInStatusSuccessState) {
                final user = state.data;

                router.goNamed(AppRoute.home.name, extra: user);
              }
            },
            child: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (_, state) {
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,

                  // -----------------------------------------------------
                  // BẬT PERFORMANCE OVERLAY ĐỂ REVIEW HIỆU SUẤT (BÀI 14)
                  // -----------------------------------------------------
                  // kProfileMode chỉ true khi bạn chạy: flutter run --profile
                  // Nghĩa là ở chế độ Debug hoặc Release, biểu đồ này sẽ tự ẩn đi.
                  showPerformanceOverlay: kProfileMode,
                  // -----------------------------------------------------
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  theme: AppTheme.data(state.isDarkMode),
                  routerConfig: router,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
