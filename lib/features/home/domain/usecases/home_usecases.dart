import 'package:fpdart/fpdart.dart';
import '../entities/home_entity.dart';
import '../failures/home_failures.dart';
import '../repositories/home_repository.dart';
import '../../data/models/home_model.dart';

class GetHomeDataUseCase {
  final HomeRepository repository;

  GetHomeDataUseCase(this.repository);

  Future<Either<HomeFailure, HomeEntity>> call() async {
    return repository.getHomeData();
  }
}

class GetAvailableDemosUseCase {
  final HomeRepository repository;

  GetAvailableDemosUseCase(this.repository);

  Future<Either<HomeFailure, List<DemoItem>>> call() async {
    return repository.getAvailableDemos();
  }
}

class LogDemoAccessUseCase {
  final HomeRepository repository;

  LogDemoAccessUseCase(this.repository);

  Future<Either<HomeFailure, void>> call(String demoId) async {
    return repository.logDemoAccess(demoId);
  }
}

// Default demo items - shared between usecases and model
final List<DemoItem> defaultDemoItems = [
  DemoItemModel(
    id: 'profiling',
    title: 'Profiling Lab',
    description: 'DevTools profiling demos',
    routeName: 'profiling',
    category: DemoCategory.profiling,
  ),
  DemoItemModel(
    id: 'repaint_boundary',
    title: 'RepaintBoundary Demo',
    description: 'UI performance optimization',
    routeName: 'repaintBoundary',
    category: DemoCategory.ui,
  ),
  DemoItemModel(
    id: 'isolate_demo',
    title: 'Isolate Demo',
    description: 'Main thread vs Isolate comparison',
    routeName: 'isolateDemo',
    category: DemoCategory.isolate,
  ),
  DemoItemModel(
    id: 'native_android',
    title: 'Method Channel (Android)',
    description: 'Android native communication',
    routeName: 'nativeAndroid',
    category: DemoCategory.native,
  ),
  DemoItemModel(
    id: 'native_ios',
    title: 'Method Channel (iOS)',
    description: 'iOS native communication',
    routeName: 'nativeIos',
    category: DemoCategory.native,
  ),
  DemoItemModel(
    id: 'permission',
    title: 'Permissions',
    description: 'Permission handling demos',
    routeName: 'permission',
    category: DemoCategory.permissions,
  ),
];
