import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/core/usecases/usecase.dart';
import 'package:task_radar/app/features/todos/domain/repositories/todo_repository.dart';

class GetTodoSummaryUseCase
    implements UseCase<({int total, int completed, int pending}), int> {
  final TodoRepository _repository;

  GetTodoSummaryUseCase(this._repository);

  @override
  Future<Either<Failure, ({int total, int completed, int pending})>> call(
    int userId,
  ) {
    return _repository.getTodoSummary(userId);
  }
}
