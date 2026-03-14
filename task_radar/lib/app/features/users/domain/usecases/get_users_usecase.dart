import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/core/usecases/usecase.dart';
import 'package:task_radar/app/features/auth/domain/entities/user.dart';
import 'package:task_radar/app/features/users/domain/repositories/user_repository.dart';

class GetUsersParams {
  final int limit;
  final int skip;

  const GetUsersParams({required this.limit, required this.skip});
}

class GetUsersUseCase
    implements UseCase<({List<User> users, int total}), GetUsersParams> {
  final UserRepository _repository;

  GetUsersUseCase(this._repository);

  @override
  Future<Either<Failure, ({List<User> users, int total})>> call(
    GetUsersParams params,
  ) {
    return _repository.getUsers(limit: params.limit, skip: params.skip);
  }
}
