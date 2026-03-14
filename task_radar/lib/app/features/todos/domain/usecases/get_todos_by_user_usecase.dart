import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/core/usecases/usecase.dart';
import 'package:task_radar/app/features/todos/domain/entities/todo.dart';
import 'package:task_radar/app/features/todos/domain/repositories/todo_repository.dart';

class GetTodosByUserParams {
  final int userId;
  final int limit;
  final int skip;

  const GetTodosByUserParams({
    required this.userId,
    required this.limit,
    required this.skip,
  });
}

class GetTodosByUserUseCase
    implements UseCase<({List<Todo> todos, int total}), GetTodosByUserParams> {
  final TodoRepository _repository;

  GetTodosByUserUseCase(this._repository);

  @override
  Future<Either<Failure, ({List<Todo> todos, int total})>> call(
    GetTodosByUserParams params,
  ) {
    return _repository.getTodosByUser(
      userId: params.userId,
      limit: params.limit,
      skip: params.skip,
    );
  }
}
