import 'package:fpdart/fpdart.dart';
import '../../../../core/api/api_exception.dart';
import '../../domain/entities/isolate_payload_entity.dart';
import '../../domain/failures/isolate_failures.dart';
import '../../domain/repositories/isolate_repository.dart';
import '../datasources/isolate_remote_data_source.dart';
import '../exceptions/isolate_exceptions.dart';

class IsolateRepositoryImpl implements IsolateRepository {
  final IsolateRemoteDataSource remoteDataSource;

  IsolateRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<IsolateFailure, IsolatePayloadEntity>> getHeavyPayload({
    required bool useIsolate,
  }) async {
    try {
      final result = await remoteDataSource.fetchHeavyPayload(
        useIsolate: useIsolate,
      );
      return Right(result);
    } on IsolateTimeoutException catch (e) {
      return Left(IsolateTimeoutFailure(e.message));
    } on FetchDataException catch (e) {
      return Left(IsolateServerFailure(e.message));
    } on BadRequestException catch (e) {
      return Left(IsolateServerFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(IsolateServerFailure(e.message));
    } on InternalServerException catch (e) {
      return Left(IsolateServerFailure(e.message));
    } on IsolateParseException catch (e) {
      return Left(IsolateParseFailure(e.message));
    } catch (e) {
      return Left(IsolateServerFailure(e.toString()));
    }
  }
}
