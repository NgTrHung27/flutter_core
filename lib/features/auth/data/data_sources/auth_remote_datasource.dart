import '../../../../core/api/api_helper.dart';
import '../../../../core/api/api_url.dart';

import '../models/login_model.dart';
import '../models/user_model.dart';

sealed class AuthRemoteDataSource {
  Future<UserModel> login(LoginModel model);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiHelper _apiHelper;

  const AuthRemoteDataSourceImpl(this._apiHelper);

  @override
  Future<UserModel> login(LoginModel model) async {
    try {
      final response = await _apiHelper.execute(
        method: Method.post,
        url: ApiUrl.login,
        data: {
          "email": model.email,
          "password": model.password,
        },
      );

      // response here is the whole Map: {"statusCode": 201, "message": "...", "data": {...}}
      final data = response['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    // Need to implement logout if needed
    throw UnimplementedError();
  }
}
