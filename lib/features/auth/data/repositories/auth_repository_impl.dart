import 'package:fpdart/fpdart.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/cache/hive_local_storage.dart';
import '../../../../core/cache/secure_local_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/usecase_params.dart';
import '../data_sources/auth_local_datasource.dart';
import '../data_sources/auth_remote_datasource.dart';

import '../models/login_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;
  final SecureLocalStorage _secureLocalStorage;
  final HiveLocalStorage _localStorage;

  const AuthRepositoryImpl(
    this._authRemoteDataSource,
    this._authLocalDataSource,
    this._secureLocalStorage,
    this._localStorage,
  );

  @override
  Future<Either<Failure, UserEntity>> login(LoginParams params) async {
    try {
      final model = LoginModel(
        email: params.email,
        password: params.password,
      );

      final result = await _authRemoteDataSource.login(model);

      // Save user info
      await _secureLocalStorage.save(
        key: "user_id",
        value: result.userId ?? "",
      );
      if (result.token != null) {
        await _secureLocalStorage.save(key: "token", value: result.token!);
      }
      await _localStorage.save(key: "user", value: result, boxName: "cache");

      return Right(result);
    } on UnauthorizedException {
      return Left(CredentialFailure());
    } on BadRequestException {
      return Left(CredentialFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _authLocalDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> checkSignInStatus() async {
    try {
      final result = await _authLocalDataSource.checkSignInStatus();

      return Right(result);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
