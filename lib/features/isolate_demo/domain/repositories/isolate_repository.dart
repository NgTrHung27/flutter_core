import 'package:fpdart/fpdart.dart';
import '../entities/isolate_payload_entity.dart';
import '../failures/isolate_failures.dart';

abstract class IsolateRepository {
  Future<Either<IsolateFailure, IsolatePayloadEntity>> getHeavyPayload({
    required bool useIsolate,
  });
}
