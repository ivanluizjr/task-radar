import 'package:sqflite/sqflite.dart';
import 'package:task_radar/app/core/errors/exceptions.dart';
import 'package:task_radar/app/features/todos/data/models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<void> cacheTodos(List<TodoModel> todos);
  Future<List<TodoModel>> getCachedTodos({
    required int limit,
    required int skip,
  });
  Future<int> getTotalCount({int? userId});
  Future<TodoModel?> getTodoById(int id);
  Future<void> insertTodo(TodoModel todo);
  Future<void> updateTodo(TodoModel todo);
  Future<void> deleteTodo(int id);
  Future<List<TodoModel>> getTodosByUser(
    int userId, {
    required int limit,
    required int skip,
  });
  Future<List<TodoModel>> searchTodos(String query);
  Future<({int total, int completed, int pending})> getSummary(int userId);
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final Database _db;

  TodoLocalDataSourceImpl(this._db);

  @override
  Future<void> cacheTodos(List<TodoModel> todos) async {
    try {
      final batch = _db.batch();
      for (final todo in todos) {
        batch.insert('todos', {
          'id': todo.id,
          'todo': todo.todo,
          'completed': todo.completed ? 1 : 0,
          'userId': todo.userId,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    } catch (e) {
      throw const CacheException('Erro ao salvar tarefas em cache');
    }
  }

  @override
  Future<List<TodoModel>> getCachedTodos({
    required int limit,
    required int skip,
  }) async {
    try {
      final result = await _db.query(
        'todos',
        limit: limit,
        offset: skip,
        orderBy: 'id ASC',
      );
      return result.map(_mapToTodoModel).toList();
    } catch (e) {
      throw const CacheException('Erro ao buscar tarefas do cache');
    }
  }

  @override
  Future<int> getTotalCount({int? userId}) async {
    final where = userId != null ? 'userId = ?' : null;
    final whereArgs = userId != null ? [userId] : null;
    final result = await _db.query(
      'todos',
      columns: ['COUNT(*) as count'],
      where: where,
      whereArgs: whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<TodoModel?> getTodoById(int id) async {
    final result = await _db.query('todos', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return _mapToTodoModel(result.first);
  }

  @override
  Future<void> insertTodo(TodoModel todo) async {
    try {
      await _db.insert('todos', {
        'id': todo.id,
        'todo': todo.todo,
        'completed': todo.completed ? 1 : 0,
        'userId': todo.userId,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw const CacheException('Erro ao inserir tarefa');
    }
  }

  @override
  Future<void> updateTodo(TodoModel todo) async {
    try {
      await _db.update(
        'todos',
        {
          'todo': todo.todo,
          'completed': todo.completed ? 1 : 0,
          'userId': todo.userId,
        },
        where: 'id = ?',
        whereArgs: [todo.id],
      );
    } catch (e) {
      throw const CacheException('Erro ao atualizar tarefa');
    }
  }

  @override
  Future<void> deleteTodo(int id) async {
    try {
      await _db.delete('todos', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw const CacheException('Erro ao excluir tarefa');
    }
  }

  @override
  Future<List<TodoModel>> getTodosByUser(
    int userId, {
    required int limit,
    required int skip,
  }) async {
    try {
      final result = await _db.query(
        'todos',
        where: 'userId = ?',
        whereArgs: [userId],
        limit: limit,
        offset: skip,
        orderBy: 'id ASC',
      );
      return result.map(_mapToTodoModel).toList();
    } catch (e) {
      throw const CacheException('Erro ao buscar tarefas do usuário');
    }
  }

  @override
  Future<List<TodoModel>> searchTodos(String query) async {
    try {
      final result = await _db.query(
        'todos',
        where: 'todo LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'id ASC',
      );
      return result.map(_mapToTodoModel).toList();
    } catch (e) {
      throw const CacheException('Erro ao buscar tarefas');
    }
  }

  @override
  Future<({int total, int completed, int pending})> getSummary(
    int userId,
  ) async {
    final totalResult = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM todos WHERE userId = ?',
      [userId],
    );
    final completedResult = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM todos WHERE userId = ? AND completed = 1',
      [userId],
    );
    final total = Sqflite.firstIntValue(totalResult) ?? 0;
    final completed = Sqflite.firstIntValue(completedResult) ?? 0;
    return (total: total, completed: completed, pending: total - completed);
  }

  TodoModel _mapToTodoModel(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as int,
      todo: map['todo'] as String,
      completed: (map['completed'] as int) == 1,
      userId: map['userId'] as int,
    );
  }
}
