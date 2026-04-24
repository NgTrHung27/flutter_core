import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_core/features/isolate_demo/domain/entities/isolate_payload_entity.dart';
import 'package:flutter_core/features/isolate_demo/domain/failures/isolate_failures.dart';
import 'package:flutter_core/features/isolate_demo/domain/usecases/get_heavy_payload_usecase.dart';
import 'package:flutter_core/features/isolate_demo/presentation/bloc/isolate_bloc.dart';
import 'package:flutter_core/features/isolate_demo/presentation/bloc/isolate_event.dart';
import 'package:flutter_core/features/isolate_demo/presentation/bloc/isolate_state.dart';
import 'package:flutter_core/features/isolate_demo/domain/repositories/isolate_repository.dart';
import 'package:fpdart/fpdart.dart';

class MockIsolateRepository extends Mock implements IsolateRepository {}

void main() {
  late IsolateBloc isolateBloc;
  late MockIsolateRepository mockIsolateRepository;

  setUp(() {
    mockIsolateRepository = MockIsolateRepository();
    final getHeavyPayloadUseCase = GetHeavyPayloadUseCase(
      mockIsolateRepository,
    );
    isolateBloc = IsolateBloc(getHeavyPayloadUseCase: getHeavyPayloadUseCase);
  });

  tearDown(() {
    isolateBloc.close();
  });

  const testPayload = IsolatePayloadEntity(
    totalRecords: 100,
    items: ['item1', 'item2', 'item3'],
  );

  group('IsolateBloc', () {
    test('initial state is IsolateInitial', () {
      expect(isolateBloc.state, isA<IsolateInitial>());
    });

    group('FetchPayloadEvent', () {
      blocTest<IsolateBloc, IsolateState>(
        'emits [IsolateLoading, IsolateLoaded] when getHeavyPayload succeeds without isolate',
        build: () {
          when(
            () => mockIsolateRepository.getHeavyPayload(useIsolate: false),
          ).thenAnswer((_) async => const Right(testPayload));
          return isolateBloc;
        },
        act: (bloc) => bloc.add(const FetchPayloadEvent(useIsolate: false)),
        expect: () => [
          isA<IsolateLoading>(),
          isA<IsolateLoaded>()
              .having((s) => s.data, 'data', testPayload)
              .having((s) => s.usedIsolate, 'usedIsolate', false),
        ],
        verify: (_) {
          verify(
            () => mockIsolateRepository.getHeavyPayload(useIsolate: false),
          ).called(1);
        },
      );

      blocTest<IsolateBloc, IsolateState>(
        'emits [IsolateLoading, IsolateLoaded] when getHeavyPayload succeeds with isolate',
        build: () {
          when(
            () => mockIsolateRepository.getHeavyPayload(useIsolate: true),
          ).thenAnswer((_) async => const Right(testPayload));
          return isolateBloc;
        },
        act: (bloc) => bloc.add(const FetchPayloadEvent(useIsolate: true)),
        expect: () => [
          isA<IsolateLoading>(),
          isA<IsolateLoaded>()
              .having((s) => s.data, 'data', testPayload)
              .having((s) => s.usedIsolate, 'usedIsolate', true),
        ],
        verify: (_) {
          verify(
            () => mockIsolateRepository.getHeavyPayload(useIsolate: true),
          ).called(1);
        },
      );

      blocTest<IsolateBloc, IsolateState>(
        'emits [IsolateLoading, IsolateError] when getHeavyPayload fails with ServerFailure',
        build: () {
          when(
            () => mockIsolateRepository.getHeavyPayload(useIsolate: false),
          ).thenAnswer((_) async => Left(IsolateServerFailure('Server error')));
          return isolateBloc;
        },
        act: (bloc) => bloc.add(const FetchPayloadEvent(useIsolate: false)),
        expect: () => [
          isA<IsolateLoading>(),
          isA<IsolateError>().having(
            (s) => s.message,
            'message',
            contains('Server error'),
          ),
        ],
      );

      blocTest<IsolateBloc, IsolateState>(
        'emits [IsolateLoading, IsolateError] when getHeavyPayload fails with TimeoutFailure',
        build: () {
          when(
            () => mockIsolateRepository.getHeavyPayload(useIsolate: false),
          ).thenAnswer(
            (_) async => Left(IsolateTimeoutFailure('Request timed out')),
          );
          return isolateBloc;
        },
        act: (bloc) => bloc.add(const FetchPayloadEvent(useIsolate: false)),
        expect: () => [
          isA<IsolateLoading>(),
          isA<IsolateError>().having(
            (s) => s.message,
            'message',
            contains('timed out'),
          ),
        ],
      );

      blocTest<IsolateBloc, IsolateState>(
        'emits [IsolateLoading, IsolateError] when getHeavyPayload fails with ParseFailure',
        build: () {
          when(
            () => mockIsolateRepository.getHeavyPayload(useIsolate: false),
          ).thenAnswer((_) async => Left(IsolateParseFailure('Parse error')));
          return isolateBloc;
        },
        act: (bloc) => bloc.add(const FetchPayloadEvent(useIsolate: false)),
        expect: () => [
          isA<IsolateLoading>(),
          isA<IsolateError>().having(
            (s) => s.message,
            'message',
            contains('Parse error'),
          ),
        ],
      );

      blocTest<IsolateBloc, IsolateState>(
        'emits [IsolateLoading, IsolateError] when getHeavyPayload fails with generic error',
        build: () {
          when(
            () => mockIsolateRepository.getHeavyPayload(useIsolate: false),
          ).thenAnswer((_) async => Left(IsolateServerFailure()));
          return isolateBloc;
        },
        act: (bloc) => bloc.add(const FetchPayloadEvent(useIsolate: false)),
        expect: () => [isA<IsolateLoading>(), isA<IsolateError>()],
      );

      blocTest<IsolateBloc, IsolateState>(
        'records execution time correctly',
        build: () {
          when(
            () => mockIsolateRepository.getHeavyPayload(useIsolate: false),
          ).thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 50));
            return const Right(testPayload);
          });
          return isolateBloc;
        },
        act: (bloc) => bloc.add(const FetchPayloadEvent(useIsolate: false)),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          isA<IsolateLoading>(),
          isA<IsolateLoaded>().having(
            (s) => s.timeTakenMs,
            'timeTakenMs',
            greaterThan(0),
          ),
        ],
      );
    });
  });
}
