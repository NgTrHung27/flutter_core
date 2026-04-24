import 'package:fpdart/fpdart.dart';
import '../entities/home_entity.dart';
import '../failures/home_failures.dart';

abstract class HomeRepository {
  Future<Either<HomeFailure, HomeEntity>> getHomeData();
  Future<Either<HomeFailure, List<DemoItem>>> getAvailableDemos();
  Future<Either<HomeFailure, void>> logDemoAccess(String demoId);
}
