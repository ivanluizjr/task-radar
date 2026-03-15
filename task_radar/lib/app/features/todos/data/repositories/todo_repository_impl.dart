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
        final mergedTodos = await _mergeRemoteWithLocal(response.todos);
        await _localDataSource.cacheTodos(mergedTodos);
        return Right((
          todos: mergedTodos.map((m) => m.toEntity()).toList(),
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
      // Na primeira página, busca tudo remotamente e popula o cache com o
      // conjunto completo (remote + local-only), garantindo que todos criados
      // localmente (que a API não persiste) apareçam na lista igual ao dashboard.
      if (skip == 0 && await _networkInfo.isConnected) {
        final remoteTodos = await _fetchAllRemoteTodosByUser(userId);
        final mergedTodos = await _mergeAllUserTodosWithLocal(
          userId: userId,
          remoteTodos: remoteTodos,
        );
        await _localDataSource.cacheTodos(mergedTodos);
        final page = mergedTodos.skip(skip).take(limit).toList();
        return Right((
          todos: page.map((m) => m.toEntity()).toList(),
          total: mergedTodos.length,
        ));
      }

      // Páginas seguintes (ou offline): lê do cache já populado acima,
      // filtrando os deleted e paginando em memória.
      final deletedIds = await _localDataSource.getDeletedTodoIds();
      final allCached = await _localDataSource.getAllTodosByUser(userId);
      final filtered = allCached
          .where((t) => !deletedIds.contains(t.id))
          .toList();
      final page = filtered.skip(skip).take(limit).toList();
      return Right((
        todos: page.map((m) => m.toEntity()).toList(),
        total: filtered.length,
      ));
    } on ServerException catch (e) {
      try {
        final deletedIds = await _localDataSource.getDeletedTodoIds();
        final allCached = await _localDataSource.getAllTodosByUser(userId);
        final filtered = allCached
            .where((t) => !deletedIds.contains(t.id))
            .toList();
        final page = filtered.skip(skip).take(limit).toList();
        return Right((
          todos: page.map((m) => m.toEntity()).toList(),
          total: filtered.length,
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
      await _localDataSource.markTodoDeleted(id);
      return Right(existing.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ({int total, int completed, int pending})>>
  getTodoSummary(int userId) async {
    try {
      final todos = await _getSummaryTodos(userId);
      final total = todos.length;
      final completed = todos.where((todo) => todo.completed).length;
      return Right((
        total: total,
        completed: completed,
        pending: total - completed,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar resumo: ${e.toString()}'));
    }
  }

  Future<List<TodoModel>> _getSummaryTodos(int userId) async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteTodos = await _fetchAllRemoteTodosByUser(userId);
        final mergedTodos = await _mergeAllUserTodosWithLocal(
          userId: userId,
          remoteTodos: remoteTodos,
        );
        await _localDataSource.cacheTodos(mergedTodos);
        return mergedTodos;
      } on ServerException {
        return _localDataSource.getAllTodosByUser(userId);
      }
    }

    return _localDataSource.getAllTodosByUser(userId);
  }

  Future<List<TodoModel>> _fetchAllRemoteTodosByUser(int userId) async {
    final allRemoteTodos = <TodoModel>[];
    var skip = 0;

    while (true) {
      final response = await _remoteDataSource.getTodosByUser(
        userId: userId,
        limit: 100,
        skip: skip,
      );
      allRemoteTodos.addAll(response.todos);
      skip += response.todos.length;
      if (skip >= response.total || response.todos.isEmpty) {
        break;
      }
    }

    return allRemoteTodos;
  }

  Future<List<TodoModel>> _mergeAllUserTodosWithLocal({
    required int userId,
    required List<TodoModel> remoteTodos,
  }) async {
    final deletedIds = await _localDataSource.getDeletedTodoIds();
    final localTodos = await _localDataSource.getAllTodosByUser(userId);
    final localTodosById = {for (final todo in localTodos) todo.id: todo};
    final mergedTodosById = <int, TodoModel>{};

    for (final remoteTodo in remoteTodos) {
      if (deletedIds.contains(remoteTodo.id)) {
        continue;
      }
      mergedTodosById[remoteTodo.id] =
          localTodosById[remoteTodo.id] ?? remoteTodo;
    }

    for (final localTodo in localTodos) {
      if (deletedIds.contains(localTodo.id)) {
        continue;
      }
      mergedTodosById.putIfAbsent(localTodo.id, () => localTodo);
    }

    return mergedTodosById.values.toList();
  }

  Future<List<TodoModel>> _mergeRemoteWithLocal(
    List<TodoModel> remoteTodos,
  ) async {
    final deletedIds = await _localDataSource.getDeletedTodoIds();
    final mergedTodos = <TodoModel>[];

    for (final remoteTodo in remoteTodos) {
      if (deletedIds.contains(remoteTodo.id)) {
        continue;
      }

      final localTodo = await _localDataSource.getTodoById(remoteTodo.id);
      if (localTodo != null) {
        mergedTodos.add(localTodo);
      } else {
        mergedTodos.add(remoteTodo);
      }
    }

    return mergedTodos;
  }
}
