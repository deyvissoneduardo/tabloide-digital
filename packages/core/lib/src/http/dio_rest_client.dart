import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tabloide_core/src/http/dio_factory.dart';
import 'package:tabloide_core/src/http/log_api_interceptor.dart';
import 'package:tabloide_core/src/http/rest_client.dart';

/// [RestClient] sobre o Dio da plataforma (`DioForNative` ou `DioForBrowser`).
///
/// O Dio lança exceção em 4xx/5xx; aqui ela volta a ser [RestResposta], para
/// o repository ler o corpo de erro da API.
final class DioRestClient implements RestClient {
  /// Cria o cliente; [dio] existe para os testes injetarem um mock.
  ///
  /// Em debug, as chamadas aparecem no console (ver [LogApiInterceptor]).
  DioRestClient({required String baseUrl, Dio? dio})
    : _dio =
          dio ??
          (criarDio(BaseOptions(baseUrl: baseUrl))
            ..interceptors.addAll([if (kDebugMode) LogApiInterceptor()]));

  final Dio _dio;

  @override
  Future<RestResposta> get(String caminho, {Map<String, dynamic>? query}) =>
      _converter(_dio.get<Object?>(caminho, queryParameters: query));

  @override
  Future<RestResposta> post(String caminho, {Object? corpo}) =>
      _converter(_dio.post<Object?>(caminho, data: corpo));

  @override
  Future<RestResposta> patch(String caminho, {Object? corpo}) =>
      _converter(_dio.patch<Object?>(caminho, data: corpo));

  @override
  Future<RestResposta> put(String caminho, {Object? corpo}) =>
      _converter(_dio.put<Object?>(caminho, data: corpo));

  @override
  Future<RestResposta> delete(String caminho) =>
      _converter(_dio.delete<Object?>(caminho));

  Future<RestResposta> _converter(Future<Response<Object?>> chamada) async {
    try {
      return _resposta(await chamada);
    } on DioException catch (erro) {
      if (erro.response case final resposta?
          when erro.type == DioExceptionType.badResponse) {
        return _resposta(resposta);
      }
      if (_semConexao.contains(erro.type)) throw const ErroSemConexao();
      rethrow;
    }
  }

  RestResposta _resposta(Response<Object?> resposta) =>
      RestResposta(status: resposta.statusCode ?? 0, dados: resposta.data);

  static const _semConexao = {
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
  };
}
