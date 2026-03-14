import 'package:dio/dio.dart';
import 'package:task_radar/app/core/constants/api_constants.dart';
import 'package:task_radar/app/core/errors/exceptions.dart';
import 'package:task_radar/app/core/network/api_client.dart';
import 'package:task_radar/app/features/quotes/data/models/quote_model.dart';

abstract class QuoteRemoteDataSource {
  Future<QuoteModel> getRandomQuote();
}

class QuoteRemoteDataSourceImpl implements QuoteRemoteDataSource {
  final ApiClient _apiClient;

  QuoteRemoteDataSourceImpl(this._apiClient);

  @override
  Future<QuoteModel> getRandomQuote() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.randomQuote);
      return QuoteModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Erro ao buscar frase',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
