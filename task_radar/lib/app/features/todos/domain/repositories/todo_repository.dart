import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/features/todos/domain/entities/todo.dart';

abstract class TodoRepository {
  Future<Either<Failure, ({List<Todo> todos, int total})>> getTodos({
    required int limit,
    required int skip,
  });

  Future<Either<Failure, ({List<Todo> todos, int total})>> getTodosByUser({
    required int userId,
    required int limit,
    required int skip,
  });

  Future<Either<Failure, Todo>> createTodo({
    required String todo,
    required bool completed,
    required int userId,
  });

  Future<Either<Failure, Todo>> updateTodo({
    required int id,
    String? todo,
    bool? completed,
  });

  Future<Either<Failure, Todo>> deleteTodo(int id);

  Future<Either<Failure, ({int total, int completed, int pending})>>
  getTodoSummary(int userId);
}
