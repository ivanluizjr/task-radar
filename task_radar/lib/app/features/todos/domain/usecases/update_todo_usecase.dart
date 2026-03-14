import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/core/usecases/usecase.dart';
import 'package:task_radar/app/features/todos/domain/entities/todo.dart';
import 'package:task_radar/app/features/todos/domain/repositories/todo_repository.dart';

class UpdateTodoParams {
  final int id;
  final String? todo;
  final bool? completed;

  const UpdateTodoParams({required this.id, this.todo, this.completed});
}

class UpdateTodoUseCase implements UseCase<Todo, UpdateTodoParams> {
  final TodoRepository _repository;

  UpdateTodoUseCase(this._repository);

  @override
  Future<Either<Failure, Todo>> call(UpdateTodoParams params) {
    return _repository.updateTodo(
      id: params.id,
      todo: params.todo,
      completed: params.completed,
    );
  }
}
