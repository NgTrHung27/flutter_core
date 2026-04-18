import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/home/presentation/pages/native_android_page.dart';
import '../../features/profiling/presentation/profiling_page.dart';
import '../../features/profiling/presentation/memory_leak_page.dart';
import '../../features/home/presentation/pages/repaint_boundary_demo_page.dart';
import '../../features/home/presentation/pages/isolate_demo_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import 'app_route_path.dart';

class AppRouteConf {
  GoRouter get router => _router;

  late final _router = GoRouter(
    initialLocation: AppRoute.splash.path,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        builder: (_, _) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoute.auth.path,
        name: AppRoute.auth.name,
        builder: (_, _) => const AuthPage(),
        routes: [
          GoRoute(
            path: AppRoute.login.path,
            name: AppRoute.login.name,
            builder: (_, _) => const LoginPage(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.home.path,
        name: AppRoute.home.name,
        builder: (_, state) {
          final user = state.extra;
          if (user is UserEntity) {
            return HomePage(user: user);
          }
          // fallback if user is missing (e.g. on direct link or web refresh)
          return const SplashPage();
        },
        routes: [
          GoRoute(
            path: AppRoute.profiling.path.replaceFirst('/', ''),
            name: AppRoute.profiling.name,
            builder: (_, _) => const ProfilingPage(),
            routes: [
              GoRoute(
                path: AppRoute.memoryLeak.path,
                name: AppRoute.memoryLeak.name,
                builder: (_, _) => const MemoryLeakPage(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoute.isolateDemo.path,
            name: AppRoute.isolateDemo.name,
            builder: (_, _) => const IsolateDemoPage(),
          ),
          GoRoute(
            path: AppRoute.nativeAndroid.path,
            name: AppRoute.nativeAndroid.name,
            builder: (_, _) => const NativeAndroidPage(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.repaintBoundary.path,
        name: AppRoute.repaintBoundary.name,
        builder: (_, _) => const RepaintBoundaryDemoPage(),
      ),
    ],
  );
}
