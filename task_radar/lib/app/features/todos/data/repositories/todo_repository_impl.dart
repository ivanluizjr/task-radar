import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/exceptions.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/core/network/network_info.dart';
import 'package:task_radar/app/features/todos/data/datasources/todo_local_datasource.dart';
import 'package:task_radar/app/features/todos/data/datasources/todo_remote_datasource.dart';
import 'package:task_radar/app/features/todos/data/models/todo_model.dart';
import 'package:task_radar/app/features/todos/domain/entities/todo.dart';
import 'package:task_radar/app/features/todos/domain/repositories/todo_repository.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource _remoteDataSource;
  final TodoLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  TodoRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, ({List<Todo> todos, int total})>> getTodos({
    required int limit,
    required int skip,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final response = await _remoteDataSource.getTodos(
          limit: limit,
          skip: skip,
        );
        await _localDataSource.cacheTodos(response.todos);
        return Right((
          todos: response.todos.map((m) => m.toEntity()).toList(),
          total: response.total,
        ));
      } else {
        final cachedTodos = await _localDataSource.getCachedTodos(
          limit: limit,
          skip: skip,
        );
        final total = await _localDataSource.getTotalCount();
        return Right((
          todos: cachedTodos.map((m) => m.toEntity()).toList(),
          total: total,
        ));
      }
    } on ServerException catch (e) {
      try {
        final cachedTodos = await _localDataSource.getCachedTodos(
          limit: limit,
          skip: skip,
        );
        final total = await _localDataSource.getTotalCount();
        return Right((
          todos: cachedTodos.map((m) => m.toEntity()).toList(),
          total: total,
        ));
      } catch (_) {
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ({List<Todo> todos, int total})>> getTodosByUser({
    required int userId,
    required int limit,
    required int skip,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final response = await _remoteDataSource.getTodosByUser(
          userId: userId,
          limit: limit,
          skip: skip,
        );
        await _localDataSource.cacheTodos(response.todos);
        return Right((
          todos: response.todos.map((m) => m.toEntity()).toList(),
          total: response.total,
        ));
      } else {
        final cachedTodos = await _localDataSource.getTodosByUser(
          userId,
          limit: limit,
          skip: skip,
        );
        final total = await _localDataSource.getTotalCount(userId: userId);
        return Right((
          todos: cachedTodos.map((m) => m.toEntity()).toList(),
          total: total,
        ));
      }
    } on ServerException catch (e) {
      try {
        final cachedTodos = await _localDataSource.getTodosByUser(
          userId,
          limit: limit,
          skip: skip,
        );
        final total = await _localDataSource.getTotalCount(userId: userId);
        return Right((
          todos: cachedTodos.map((m) => m.toEntity()).toList(),
          total: total,
        ));
      } catch (_) {
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Todo>> createTodo({
    required String todo,
    required bool completed,
    required int userId,
  }) async {
    try {
      TodoModel newTodo;

      if (await _networkInfo.isConnected) {
        newTodo = await _remoteDataSource.createTodo(
          todo: todo,
          completed: completed,
          userId: userId,
        );
        newTodo = TodoModel(
          id: DateTime.now().millisecondsSinceEpoch,
          todo: newTodo.todo,
          completed: newTodo.completed,
          userId: newTodo.userId,
        );
      } else {
        newTodo = TodoModel(
          id: DateTime.now().millisecondsSinceEpoch,
          todo: todo,
          completed: completed,
          userId: userId,
        );
      }

      await _localDataSource.insertTodo(newTodo);
      return Right(newTodo.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Todo>> updateTodo({
    required int id,
    String? todo,
    bool? completed,
  }) async {
    try {
      final existing = await _localDataSource.getTodoById(id);
      if (existing == null) {
        return const Left(CacheFailure('Tarefa não encontrada'));
      }

      final updated = TodoModel(
        id: existing.id,
        todo: todo ?? existing.todo,
        completed: completed ?? existing.completed,
        userId: existing.userId,
      );

      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.updateTodo(
            id: id,
            todo: todo,
            completed: completed,
          );
        } catch (_) {}
      }

      await _localDataSource.updateTodo(updated);
      return Right(updated.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Todo>> deleteTodo(int id) async {
    try {
      final existing = await _localDataSource.getTodoById(id);
      if (existing == null) {
        return const Left(CacheFailure('Tarefa não encontrada'));
      }

      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.deleteTodo(id);
        } catch (_) {}
      }

      await _localDataSource.deleteTodo(id);
      return Right(existing.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ({int total, int completed, int pending})>>
  getTodoSummary(int userId) async {
    try {
      final summary = await _localDataSource.getSummary(userId);
      return Right(summary);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar resumo: ${e.toString()}'));
    }
  }
}
