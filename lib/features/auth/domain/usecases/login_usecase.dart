import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_core/core/errors/failures.dart';
import 'package:flutter_core/core/usecases/uscases.dart';
import 'package:flutter_core/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_core/features/auth/domain/repositories/auth_repository.dart';

class AuthLoginUseCase implements UseCase<UserEntity, Params> {
  final AuthRepository repository;

  AuthLoginUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(Params params) async {
    return await repository.login(params);
  }
}

class Params extends Equatable {
  final String email;
  final String password;

  const Params({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

/*
Domain Layer
  ├── Entity ✅
  ├── Repository (abstract) ✅
  └── UseCase ✅ ← BẠN ĐANG Ở ĐÂY
*/
// Gom các Params class từ các UseCase thành typedef dùng chung, 
//để Repository abstract có thể import 1 file thay vì import từng usecase
