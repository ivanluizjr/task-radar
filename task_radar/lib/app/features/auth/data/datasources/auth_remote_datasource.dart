import 'package:dio/dio.dart';
import 'package:task_radar/app/core/constants/api_constants.dart';
import 'package:task_radar/app/core/errors/exceptions.dart';
import 'package:task_radar/app/core/network/api_client.dart';
import 'package:task_radar/app/features/auth/data/models/login_response_model.dart';
import 'package:task_radar/app/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login({
    required String username,
    required String password,
  });

  Future<LoginResponseModel> refreshToken(String refreshToken);

  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<LoginResponseModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: {'username': username, 'password': password, 'expiresInMins': 60},
      );
      return LoginResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        final message = e.response?.data['message'] ?? 'Credenciais inválidas';
        throw AuthException(message);
      }
      throw ServerException(
        e.message ?? 'Erro ao fazer login',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<LoginResponseModel> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken, 'expiresInMins': 60},
      );
      return LoginResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Erro ao renovar token',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.currentUser);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Erro ao buscar usuário',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
