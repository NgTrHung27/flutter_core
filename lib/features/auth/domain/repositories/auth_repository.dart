import 'package:fpdart/fpdart.dart';
import 'package:flutter_core/core/errors/failures.dart';
import 'package:flutter_core/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_core/features/auth/domain/usecases/usecase_params.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(LoginParams params);
  Future<Either<Failure, UserEntity>> checkSignInStatus();
  Future<Either<Failure, void>> logout();
}

/* Thay vì:
try {
  final user = await repo.login(params);  // throw nếu lỗi
} catch (e) { ... }
// Clean Architecture dùng:
final result = await repo.login(params);  // luôn trả về Either
result.fold(
  (failure) => /* xử lý lỗi */,
  (user)    => /* xử lý thành công */,
); 
*/


// Điểm mấu chốt: UseCase sẽ gọi Repository abstract này, không bao giờ gọi trực tiếp RepositoryImpl. 
//Khi chạy app, get_it sẽ inject RepositoryImpl vào.

/*
Domain Layer
  ├── Entity ✅ (đã làm)
  ├── Repository (abstract) ✅ ← BẠN ĐANG Ở ĐÂY
  │     ↑
  │     │ implements
  │     │
  Data Layer
  └── RepositoryImpl (sẽ làm sau)
*/