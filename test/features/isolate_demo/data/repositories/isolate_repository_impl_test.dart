import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_core/features/isolate_demo/data/datasources/isolate_remote_data_source.dart';
import 'package:flutter_core/features/isolate_demo/data/exceptions/isolate_exceptions.dart';
import 'package:flutter_core/features/isolate_demo/data/models/isolate_payload_model.dart';
import 'package:flutter_core/features/isolate_demo/data/repositories/isolate_repository_impl.dart';
import 'package:flutter_core/features/isolate_demo/domain/failures/isolate_failures.dart';
import 'package:flutter_core/core/api/api_exception.dart';

class MockIsolateRemoteDataSource extends Mock implements IsolateRemoteDataSource {}

void main() {
  late IsolateRepositoryImpl repository;
  late MockIsolateRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockIsolateRemoteDataSource();
    repository = IsolateRepositoryImpl(remoteDataSource: mockDataSource);
  });

  const testPayload = IsolatePayloadModel(
    totalRecords: 100,
    items: ['item1', 'item2'],
  );

  group('IsolateRepositoryImpl', () {
    group('getHeavyPayload', () {
      test('returns Right(IsolatePayloadEntity) when data source succeeds', () async {
        when(() => mockDataSource.fetchHeavyPayload(useIsolate: false))
            .thenAnswer((_) async => testPayload);

        final result = await repository.getHeavyPayload(useIsolate: false);

        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should not return Left'),
          (r) {
            expect(r.totalRecords, 100);
            expect(r.items.length, 2);
          },
        );
        verify(() => mockDataSource.fetchHeavyPayload(useIsolate: false)).called(1);
      });

      test('returns Left(IsolateServerFailure) on FetchDataException', () async {
        when(() => mockDataSource.fetchHeavyPayload(useIsolate: false))
            .thenThrow(FetchDataException('Network error'));

        final result = await repository.getHeavyPayload(useIsolate: false);

        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<IsolateServerFailure>()),
          (r) => fail('Should not return Right'),
        );
      });

      test('returns Left(IsolateServerFailure) on BadRequestException', () async {
        when(() => mockDataSource.fetchHeavyPayload(useIsolate: false))
            .thenThrow(BadRequestException('Bad request'));

        final result = await repository.getHeavyPayload(useIsolate: false);

        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<IsolateServerFailure>()),
          (r) => fail('Should not return Right'),
        );
      });

      test('returns Left(IsolateServerFailure) on NotFoundException', () async {
        when(() => mockDataSource.fetchHeavyPayload(useIsolate: false))
            .thenThrow(NotFoundException('Not found'));

        final result = await repository.getHeavyPayload(useIsolate: false);

        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<IsolateServerFailure>()),
          (r) => fail('Should not return Right'),
        );
      });

      test('returns Left(IsolateServerFailure) on InternalServerException', () async {
        when(() => mockDataSource.fetchHeavyPayload(useIsolate: false))
            .thenThrow(InternalServerException('Server error'));

        final result = await repository.getHeavyPayload(useIsolate: false);

        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<IsolateServerFailure>()),
          (r) => fail('Should not return Right'),
        );
      });

      test('returns Left(IsolateParseFailure) on IsolateParseException', () async {
        when(() => mockDataSource.fetchHeavyPayload(useIsolate: false))
            .thenThrow(IsolateParseException('Parse error'));

        final result = await repository.getHeavyPayload(useIsolate: false);

        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<IsolateParseFailure>()),
          (r) => fail('Should not return Right'),
        );
      });

      test('returns Left(IsolateTimeoutFailure) on IsolateTimeoutException', () async {
        when(() => mockDataSource.fetchHeavyPayload(useIsolate: false))
            .thenThrow(IsolateTimeoutException('Timeout'));

        final result = await repository.getHeavyPayload(useIsolate: false);

        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<IsolateTimeoutFailure>()),
          (r) => fail('Should not return Right'),
        );
      });

      test('returns Left(IsolateServerFailure) on generic exception', () async {
        when(() => mockDataSource.fetchHeavyPayload(useIsolate: false))
            .thenThrow(Exception('Unknown error'));

        final result = await repository.getHeavyPayload(useIsolate: false);

        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<IsolateServerFailure>()),
          (r) => fail('Should not return Right'),
        );
      });

      test('works with useIsolate = true', () async {
        when(() => mockDataSource.fetchHeavyPayload(useIsolate: true))
            .thenAnswer((_) async => testPayload);

        final result = await repository.getHeavyPayload(useIsolate: true);

        expect(result.isRight(), true);
        verify(() => mockDataSource.fetchHeavyPayload(useIsolate: true)).called(1);
      });
    });
  });
}
