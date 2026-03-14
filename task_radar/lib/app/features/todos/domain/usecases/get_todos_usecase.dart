import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/core/usecases/usecase.dart';
import 'package:task_radar/app/features/todos/domain/entities/todo.dart';
import 'package:task_radar/app/features/todos/domain/repositories/todo_repository.dart';

class GetTodosParams {
  final int limit;
  final int skip;

  const GetTodosParams({required this.limit, required this.skip});
}

class GetTodosUseCase
    implements UseCase<({List<Todo> todos, int total}), GetTodosParams> {
  final TodoRepository _repository;

  GetTodosUseCase(this._repository);

  @override
  Future<Either<Failure, ({List<Todo> todos, int total})>> call(
    GetTodosParams params,
  ) {
    return _repository.getTodos(limit: params.limit, skip: params.skip);
  }
}
