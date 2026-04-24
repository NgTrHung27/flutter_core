import 'package:fpdart/fpdart.dart';
import '../../domain/entities/home_entity.dart';
import '../../domain/failures/home_failures.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource localDataSource;

  HomeRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<HomeFailure, HomeEntity>> getHomeData() async {
    try {
      final result = await localDataSource.getHomeData();
      return Right(result);
    } catch (e) {
      return Left(HomeCacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<HomeFailure, List<DemoItem>>> getAvailableDemos() async {
    try {
      final result = await localDataSource.getAvailableDemos();
      return Right(result);
    } catch (e) {
      return Left(HomeCacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<HomeFailure, void>> logDemoAccess(String demoId) async {
    try {
      await localDataSource.saveDemoAccessLog(demoId);
      return const Right(null);
    } catch (e) {
      return Left(HomeCacheFailure(e.toString()));
    }
  }
}
