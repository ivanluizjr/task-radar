import 'package:dio/dio.dart';
import 'package:task_radar/app/core/constants/api_constants.dart';
import 'package:task_radar/app/core/errors/exceptions.dart';
import 'package:task_radar/app/core/network/api_client.dart';
import 'package:task_radar/app/features/todos/data/models/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<TodoListResponseModel> getTodos({
    required int limit,
    required int skip,
  });

  Future<TodoListResponseModel> getTodosByUser({
    required int userId,
    required int limit,
    required int skip,
  });

  Future<TodoModel> createTodo({
    required String todo,
    required bool completed,
    required int userId,
  });

  Future<TodoModel> updateTodo({
    required int id,
    String? todo,
    bool? completed,
  });

  Future<TodoModel> deleteTodo(int id);
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final ApiClient _apiClient;

  TodoRemoteDataSourceImpl(this._apiClient);

  @override
  Future<TodoListResponseModel> getTodos({
    required int limit,
    required int skip,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.todos,
        queryParameters: {'limit': limit, 'skip': skip},
      );
      return TodoListResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Erro ao buscar tarefas',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<TodoListResponseModel> getTodosByUser({
    required int userId,
    required int limit,
    required int skip,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.todosByUser(userId),
        queryParameters: {'limit': limit, 'skip': skip},
      );
      return TodoListResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Erro ao buscar tarefas do usuário',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<TodoModel> createTodo({
    required String todo,
    required bool completed,
    required int userId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.addTodo,
        data: {'todo': todo, 'completed': completed, 'userId': userId},
      );
      return TodoModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Erro ao criar tarefa',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<TodoModel> updateTodo({
    required int id,
    String? todo,
    bool? completed,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (todo != null) data['todo'] = todo;
      if (completed != null) data['completed'] = completed;

      final response = await _apiClient.dio.put(
        ApiConstants.todoById(id),
        data: data,
      );
      return TodoModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Erro ao atualizar tarefa',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<TodoModel> deleteTodo(int id) async {
    try {
      final response = await _apiClient.dio.delete(ApiConstants.todoById(id));
      return TodoModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Erro ao excluir tarefa',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
