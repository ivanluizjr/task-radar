import 'package:task_radar/app/core/either/either.dart';
import 'package:task_radar/app/core/errors/failures.dart';
import 'package:task_radar/app/features/quotes/domain/entities/quote.dart';

abstract class QuoteRepository {
  Future<Either<Failure, Quote>> getRandomQuote();
}
