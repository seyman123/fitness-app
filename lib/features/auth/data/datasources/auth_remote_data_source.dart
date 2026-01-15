import '../../../../core/network/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    String? name,
  });

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> getCurrentUser(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await apiClient.post(
      '${ApiConfig.auth}/register',
      body: {
        'email': email,
        'password': password,
        if (name != null) 'name': name,
      },
    );

    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      '${ApiConfig.auth}/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<UserModel> getCurrentUser(String token) async {
    final response = await apiClient.get(
      '${ApiConfig.auth}/me',
      token: token,
    );

    return UserModel.fromJson(response['user'] as Map<String, dynamic>);
  }
}
