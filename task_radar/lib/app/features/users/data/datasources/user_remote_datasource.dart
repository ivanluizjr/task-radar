import 'package:dio/dio.dart';
import 'package:task_radar/app/core/constants/api_constants.dart';
import 'package:task_radar/app/core/errors/exceptions.dart';
import 'package:task_radar/app/core/network/api_client.dart';
import 'package:task_radar/app/features/auth/data/models/user_model.dart';
import 'package:task_radar/app/features/users/data/models/user_list_response_model.dart';

abstract class UserRemoteDataSource {
  Future<UserListResponseModel> getUsers({
    required int limit,
    required int skip,
  });

  Future<UserModel> getUserById(int id);

  Future<UserListResponseModel> searchUsers(String query);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient _apiClient;

  UserRemoteDataSourceImpl(this._apiClient);

  @override
  Future<UserListResponseModel> getUsers({
    required int limit,
    required int skip,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.users,
        queryParameters: {'limit': limit, 'skip': skip},
      );
      return UserListResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Erro ao buscar usuários',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<UserModel> getUserById(int id) async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.userById(id));
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Erro ao buscar usuário',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<UserListResponseModel> searchUsers(String query) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.searchUsers,
        queryParameters: {'q': query},
      );
      return UserListResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Erro ao buscar usuários',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
