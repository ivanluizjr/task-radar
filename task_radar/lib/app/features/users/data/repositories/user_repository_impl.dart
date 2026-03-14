import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/exceptions.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/core/network/network_info.dart';
import 'package:task_radar/app/features/auth/domain/entities/user.dart';
import 'package:task_radar/app/features/users/data/datasources/user_local_datasource.dart';
import 'package:task_radar/app/features/users/data/datasources/user_remote_datasource.dart';
import 'package:task_radar/app/features/users/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;
  final UserLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  UserRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, ({List<User> users, int total})>> getUsers({
    required int limit,
    required int skip,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final response = await _remoteDataSource.getUsers(
          limit: limit,
          skip: skip,
        );
        await _localDataSource.cacheUsers(response.users);
        return Right((
          users: response.users.map((m) => m.toEntity()).toList(),
          total: response.total,
        ));
      } else {
        final cached = await _localDataSource.getCachedUsers(
          limit: limit,
          skip: skip,
        );
        final total = await _localDataSource.getTotalCount();
        return Right((
          users: cached.map((m) => m.toEntity()).toList(),
          total: total,
        ));
      }
    } on ServerException catch (e) {
      try {
        final cached = await _localDataSource.getCachedUsers(
          limit: limit,
          skip: skip,
        );
        final total = await _localDataSource.getTotalCount();
        return Right((
          users: cached.map((m) => m.toEntity()).toList(),
          total: total,
        ));
      } catch (_) {
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> getUserById(int id) async {
    try {
      if (await _networkInfo.isConnected) {
        final user = await _remoteDataSource.getUserById(id);
        return Right(user.toEntity());
      } else {
        final cached = await _localDataSource.getUserById(id);
        if (cached != null) {
          return Right(cached.toEntity());
        }
        return const Left(CacheFailure('Usuário não encontrado no cache'));
      }
    } on ServerException catch (e) {
      final cached = await _localDataSource.getUserById(id);
      if (cached != null) {
        return Right(cached.toEntity());
      }
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ({List<User> users, int total})>> searchUsers(
    String query,
  ) async {
    try {
      if (await _networkInfo.isConnected) {
        final response = await _remoteDataSource.searchUsers(query);
        return Right((
          users: response.users.map((m) => m.toEntity()).toList(),
          total: response.total,
        ));
      } else {
        return const Left(
          NetworkFailure('Busca requer conexão com a internet'),
        );
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
