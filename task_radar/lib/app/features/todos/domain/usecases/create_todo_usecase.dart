import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/core/usecases/usecase.dart';
import 'package:task_radar/app/features/todos/domain/entities/todo.dart';
import 'package:task_radar/app/features/todos/domain/repositories/todo_repository.dart';

class CreateTodoParams {
  final String todo;
  final bool completed;
  final int userId;

  const CreateTodoParams({
    required this.todo,
    this.completed = false,
    required this.userId,
  });
}

class CreateTodoUseCase implements UseCase<Todo, CreateTodoParams> {
  final TodoRepository _repository;

  CreateTodoUseCase(this._repository);

  @override
  Future<Either<Failure, Todo>> call(CreateTodoParams params) {
    return _repository.createTodo(
      todo: params.todo,
      completed: params.completed,
      userId: params.userId,
    );
  }
}
