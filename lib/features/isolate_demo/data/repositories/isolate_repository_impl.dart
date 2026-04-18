import '../../domain/entities/isolate_payload_entity.dart';
import '../../domain/repositories/isolate_repository.dart';
import '../datasources/isolate_remote_data_source.dart';

class IsolateRepositoryImpl implements IsolateRepository {
  final IsolateRemoteDataSource remoteDataSource;

  IsolateRepositoryImpl({required this.remoteDataSource});

  @override
  Future<IsolatePayloadEntity> getHeavyPayload({required bool useIsolate}) async {
    return await remoteDataSource.fetchHeavyPayload(useIsolate: useIsolate);
  }
}
