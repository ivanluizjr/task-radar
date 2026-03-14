import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/core/usecases/usecase.dart';
import 'package:task_radar/app/features/todos/domain/entities/todo.dart';
import 'package:task_radar/app/features/todos/domain/repositories/todo_repository.dart';

class DeleteTodoUseCase implements UseCase<Todo, int> {
  final TodoRepository _repository;

  DeleteTodoUseCase(this._repository);

  @override
  Future<Either<Failure, Todo>> call(int id) {
    return _repository.deleteTodo(id);
  }
}
