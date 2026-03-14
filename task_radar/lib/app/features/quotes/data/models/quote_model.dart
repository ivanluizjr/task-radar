import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_radar/app/features/quotes/domain/entities/quote.dart';

part 'quote_model.freezed.dart';
part 'quote_model.g.dart';

@freezed
abstract class QuoteModel with _$QuoteModel {
  const QuoteModel._();

  const factory QuoteModel({
    required int id,
    required String quote,
    required String author,
  }) = _QuoteModel;

  factory QuoteModel.fromJson(Map<String, dynamic> json) =>
      _$QuoteModelFromJson(json);

  Quote toEntity() => Quote(id: id, quote: quote, author: author);
}
