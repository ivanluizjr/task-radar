import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/exceptions.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/features/quotes/data/datasources/quote_remote_datasource.dart';
import 'package:task_radar/app/features/quotes/domain/entities/quote.dart';
import 'package:task_radar/app/features/quotes/domain/repositories/quote_repository.dart';

class QuoteRepositoryImpl implements QuoteRepository {
  final QuoteRemoteDataSource _remoteDataSource;

  QuoteRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, Quote>> getRandomQuote() async {
    try {
      final model = await _remoteDataSource.getRandomQuote();
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar frase: ${e.toString()}'));
    }
  }
}
