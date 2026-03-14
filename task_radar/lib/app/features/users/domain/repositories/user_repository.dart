import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/features/auth/domain/entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, ({List<User> users, int total})>> getUsers({
    required int limit,
    required int skip,
  });

  Future<Either<Failure, User>> getUserById(int id);

  Future<Either<Failure, ({List<User> users, int total})>> searchUsers(
    String query,
  );
}
