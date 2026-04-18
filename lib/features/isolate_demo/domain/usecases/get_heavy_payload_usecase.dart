import '../entities/isolate_payload_entity.dart';
import '../repositories/isolate_repository.dart';

class GetHeavyPayloadUseCase {
  final IsolateRepository repository;

  GetHeavyPayloadUseCase(this.repository);

  Future<IsolatePayloadEntity> call({required bool useIsolate}) async {
    return repository.getHeavyPayload(useIsolate: useIsolate);
  }
}
