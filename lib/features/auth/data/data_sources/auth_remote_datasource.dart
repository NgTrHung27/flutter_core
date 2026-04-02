import '../../../../core/api/api_url.dart';
import '../../../../core/constants/error_message.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/login_model.dart';
import '../models/user_model.dart';

sealed class AuthRemoteDataSource {
  Future<UserModel> login(LoginModel model);
  Future<void> logout();
}

// 
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> login(LoginModel model) async {
    try {
      final user = await _getUserByEmail(model.email ?? "");
      return user;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> logout() async {
    // TODO: implement logout
    // Need to implement logout because implements medthod AuthRemoteDataSource
    throw UnimplementedError();
  }

  Future<UserModel> _getUserByEmail(String email) async {
    try {
      final result = await ApiUrl.users.where("email", isEqualTo: email).get();
      final doc = result.docs.first;
      final user = UserModel.fromJson(doc.data(), doc.id);

      return user;
    } catch (e) {
      if (e.toString() == noElement) {
        throw EmptyException();
      }
      logger.e(e);
      throw ServerException();
    }
  }
}
