import 'package:fpdart/fpdart.dart';
import '../entities/isolate_payload_entity.dart';
import '../failures/isolate_failures.dart';
import '../repositories/isolate_repository.dart';

class GetHeavyPayloadUseCase {
  final IsolateRepository repository;

  GetHeavyPayloadUseCase(this.repository);

  Future<Either<IsolateFailure, IsolatePayloadEntity>> call({
    required bool useIsolate,
  }) async {
    return repository.getHeavyPayload(useIsolate: useIsolate);
  }
}
