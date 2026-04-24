import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_core/features/home/domain/entities/home_entity.dart';
import 'package:flutter_core/features/home/domain/failures/home_failures.dart';
import 'package:flutter_core/features/home/domain/usecases/home_usecases.dart';
import 'package:flutter_core/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_core/features/home/presentation/bloc/home_event.dart';
import 'package:flutter_core/features/home/presentation/bloc/home_state.dart';
import 'package:flutter_core/features/home/domain/repositories/home_repository.dart';
import 'package:fpdart/fpdart.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late HomeBloc homeBloc;
  late MockHomeRepository mockHomeRepository;

  final testHomeEntity = HomeEntity(
    welcomeMessage: 'Test Welcome',
    availableDemos: const [],
    totalDemos: 0,
  );

  final testDemos = <DemoItem>[
    DemoItem(
      id: 'demo1',
      title: 'Demo 1',
      description: 'Test demo',
      routeName: 'demo1',
      category: DemoCategory.profiling,
    ),
    DemoItem(
      id: 'demo2',
      title: 'Demo 2',
      description: 'Test demo 2',
      routeName: 'demo2',
      category: DemoCategory.isolate,
    ),
  ];

  setUp(() {
    mockHomeRepository = MockHomeRepository();
    final getHomeDataUseCase = GetHomeDataUseCase(mockHomeRepository);
    final getAvailableDemosUseCase = GetAvailableDemosUseCase(mockHomeRepository);
    final logDemoAccessUseCase = LogDemoAccessUseCase(mockHomeRepository);

    homeBloc = HomeBloc(
      getHomeDataUseCase: getHomeDataUseCase,
      getAvailableDemosUseCase: getAvailableDemosUseCase,
      logDemoAccessUseCase: logDemoAccessUseCase,
    );
  });

  tearDown(() {
    homeBloc.close();
  });

  group('HomeBloc', () {
    test('initial state is HomeInitial', () {
      expect(homeBloc.state, isA<HomeInitial>());
    });

    group('LoadHomeDataEvent', () {
      blocTest<HomeBloc, HomeState>(
        'emits [HomeLoading, HomeLoaded] when getHomeData succeeds',
        build: () {
          when(() => mockHomeRepository.getHomeData())
              .thenAnswer((_) async => Right(testHomeEntity));
          when(() => mockHomeRepository.getAvailableDemos())
              .thenAnswer((_) async => Right(testDemos));
          return homeBloc;
        },
        act: (bloc) => bloc.add(LoadHomeDataEvent()),
        expect: () => [
          isA<HomeLoading>(),
          isA<HomeLoaded>()
              .having((s) => s.homeData, 'homeData', testHomeEntity)
              .having((s) => s.demos, 'demos', testDemos),
        ],
        verify: (_) {
          verify(() => mockHomeRepository.getHomeData()).called(1);
          verify(() => mockHomeRepository.getAvailableDemos()).called(1);
        },
      );

      blocTest<HomeBloc, HomeState>(
        'emits [HomeLoading, HomeError] when getHomeData fails',
        build: () {
          when(() => mockHomeRepository.getHomeData())
              .thenAnswer((_) async => Left(HomeCacheFailure('Cache error')));
          return homeBloc;
        },
        act: (bloc) => bloc.add(LoadHomeDataEvent()),
        expect: () => [
          isA<HomeLoading>(),
          isA<HomeError>()
              .having((s) => s.message, 'message', contains('Cache error')),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'emits [HomeLoading, HomeError] when getAvailableDemos fails',
        build: () {
          when(() => mockHomeRepository.getHomeData())
              .thenAnswer((_) async => Right(testHomeEntity));
          when(() => mockHomeRepository.getAvailableDemos())
              .thenAnswer((_) async => Left(HomeCacheFailure('Cache error')));
          return homeBloc;
        },
        act: (bloc) => bloc.add(LoadHomeDataEvent()),
        expect: () => [
          isA<HomeLoading>(),
          isA<HomeError>()
              .having((s) => s.message, 'message', contains('Cache error')),
        ],
      );
    });

    group('LogDemoAccessEvent', () {
      blocTest<HomeBloc, HomeState>(
        'calls logDemoAccess without changing state',
        build: () {
          when(() => mockHomeRepository.logDemoAccess(any()))
              .thenAnswer((_) async => const Right(null));
          return homeBloc;
        },
        act: (bloc) => bloc.add(const LogDemoAccessEvent('demo1')),
        expect: () => <HomeState>[],
        verify: (_) {
          verify(() => mockHomeRepository.logDemoAccess('demo1')).called(1);
        },
      );
    });

    group('RefreshHomeEvent', () {
      blocTest<HomeBloc, HomeState>(
        'triggers LoadHomeDataEvent',
        build: () {
          when(() => mockHomeRepository.getHomeData())
              .thenAnswer((_) async => Right(testHomeEntity));
          when(() => mockHomeRepository.getAvailableDemos())
              .thenAnswer((_) async => Right(testDemos));
          return homeBloc;
        },
        act: (bloc) => bloc.add(RefreshHomeEvent()),
        expect: () => [
          isA<HomeLoading>(),
          isA<HomeLoaded>(),
        ],
      );
    });
  });
}
