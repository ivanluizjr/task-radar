import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/core/usecases/usecase.dart';
import 'package:task_radar/app/features/quotes/domain/entities/quote.dart';
import 'package:task_radar/app/features/quotes/domain/repositories/quote_repository.dart';

class GetRandomQuoteUseCase implements UseCase<Quote, NoParams> {
  final QuoteRepository _repository;

  GetRandomQuoteUseCase(this._repository);

  @override
  Future<Either<Failure, Quote>> call(NoParams params) {
    return _repository.getRandomQuote();
  }
}
