import '../entities/isolate_payload_entity.dart';

abstract class IsolateRepository {
  Future<IsolatePayloadEntity> getHeavyPayload({required bool useIsolate});
}
