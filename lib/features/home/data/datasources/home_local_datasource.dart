import '../../domain/entities/home_entity.dart';
import '../../domain/usecases/home_usecases.dart';
import '../models/home_model.dart';

abstract class HomeLocalDataSource {
  Future<HomeModel> getHomeData();
  Future<List<DemoItem>> getAvailableDemos();
  Future<void> saveDemoAccessLog(String demoId);
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final Map<String, DateTime> _accessLog = {};

  @override
  Future<HomeModel> getHomeData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return HomeModel.defaultHome();
  }

  @override
  Future<List<DemoItem>> getAvailableDemos() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return defaultDemoItems;
  }

  @override
  Future<void> saveDemoAccessLog(String demoId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    _accessLog[demoId] = DateTime.now();
  }
}
