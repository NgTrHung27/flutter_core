import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_core/features/home/data/datasources/home_local_datasource.dart';
import 'package:flutter_core/features/home/data/models/home_model.dart';
import 'package:flutter_core/features/home/data/repositories/home_repository_impl.dart';
import 'package:flutter_core/features/home/domain/failures/home_failures.dart';

class MockHomeLocalDataSource extends Mock implements HomeLocalDataSource {}

void main() {
  late HomeRepositoryImpl repository;
  late MockHomeLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockHomeLocalDataSource();
    repository = HomeRepositoryImpl(localDataSource: mockDataSource);
  });

  group('HomeRepositoryImpl', () {
    group('getHomeData', () {
      test('returns Right(HomeEntity) when data source succeeds', () async {
        final testHomeModel = HomeModel.defaultHome();
        when(() => mockDataSource.getHomeData())
            .thenAnswer((_) async => testHomeModel);

        final result = await repository.getHomeData();

        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should not return Left'),
          (r) {
            expect(r.welcomeMessage, 'Welcome to Flutter Core');
            expect(r.totalDemos, greaterThan(0));
          },
        );
        verify(() => mockDataSource.getHomeData()).called(1);
      });

      test('returns Left(HomeCacheFailure) when data source throws', () async {
        when(() => mockDataSource.getHomeData())
            .thenThrow(Exception('Cache error'));

        final result = await repository.getHomeData();

        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<HomeCacheFailure>()),
          (r) => fail('Should not return Right'),
        );
      });
    });

    group('getAvailableDemos', () {
      test('returns Right(List<DemoItem>) when data source succeeds', () async {
        final testDemos = HomeModel.defaultHome().availableDemos;
        when(() => mockDataSource.getAvailableDemos())
            .thenAnswer((_) async => testDemos);

        final result = await repository.getAvailableDemos();

        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should not return Left'),
          (r) => expect(r.length, testDemos.length),
        );
        verify(() => mockDataSource.getAvailableDemos()).called(1);
      });

      test('returns Left(HomeCacheFailure) when data source throws', () async {
        when(() => mockDataSource.getAvailableDemos())
            .thenThrow(Exception('Cache error'));

        final result = await repository.getAvailableDemos();

        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<HomeCacheFailure>()),
          (r) => fail('Should not return Right'),
        );
      });
    });

    group('logDemoAccess', () {
      test('returns Right(null) when data source succeeds', () async {
        when(() => mockDataSource.saveDemoAccessLog(any()))
            .thenAnswer((_) async {});

        final result = await repository.logDemoAccess('demo1');

        expect(result.isRight(), true);
        verify(() => mockDataSource.saveDemoAccessLog('demo1')).called(1);
      });

      test('returns Left(HomeCacheFailure) when data source throws', () async {
        when(() => mockDataSource.saveDemoAccessLog(any()))
            .thenThrow(Exception('Cache error'));

        final result = await repository.logDemoAccess('demo1');

        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<HomeCacheFailure>()),
          (r) => fail('Should not return Right'),
        );
      });
    });
  });
}
