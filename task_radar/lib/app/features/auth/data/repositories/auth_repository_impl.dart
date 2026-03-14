import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/exceptions.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/core/network/network_info.dart';
import 'package:task_radar/app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:task_radar/app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:task_radar/app/features/auth/domain/entities/user.dart';
import 'package:task_radar/app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(const NetworkFailure('Sem conexão com a internet'));
    }

    try {
      final response = await _remoteDataSource.login(
        username: username,
        password: password,
      );

      await _localDataSource.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      final userModel = await _remoteDataSource.getCurrentUser();
      await _localDataSource.cacheUser(userModel);

      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      if (await _networkInfo.isConnected) {
        final userModel = await _remoteDataSource.getCurrentUser();
        await _localDataSource.cacheUser(userModel);
        return Right(userModel.toEntity());
      } else {
        final cachedUser = await _localDataSource.getCachedUser();
        if (cachedUser != null) {
          return Right(cachedUser.toEntity());
        }
        return const Left(CacheFailure('Nenhum dado em cache disponível'));
      }
    } on ServerException catch (e) {
      final cachedUser = await _localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _localDataSource.clearTokens();
      await _localDataSource.clearCachedUser();
      return Right(Unit.instance);
    } catch (e) {
      return Left(CacheFailure('Erro ao fazer logout: ${e.toString()}'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _localDataSource.getAccessToken();
    return token != null;
  }
}
