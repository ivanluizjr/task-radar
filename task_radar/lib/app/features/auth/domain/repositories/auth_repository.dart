import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
  });

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, Unit>> logout();

  Future<bool> isAuthenticated();
}
