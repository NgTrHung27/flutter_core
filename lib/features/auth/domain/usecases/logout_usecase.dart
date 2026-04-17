import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/uscases.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthLogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository _repository;

  AuthLogoutUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.logout();
  }
}
