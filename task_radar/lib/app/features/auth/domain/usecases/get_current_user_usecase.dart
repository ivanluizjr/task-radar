import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/core/usecases/usecase.dart';
import 'package:task_radar/app/features/auth/domain/entities/user.dart';
import 'package:task_radar/app/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase implements UseCase<User, NoParams> {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return _repository.getCurrentUser();
  }
}
