import 'package:dio/dio.dart';
import 'package:tabloide_core/src/http/dio_factory.dart';
import 'package:tabloide_core/src/http/rest_client.dart';

/// [RestClient] sobre o Dio da plataforma (`DioForNative` ou `DioForBrowser`).
final class DioRestClient implements RestClient {
  /// Cria o cliente; [dio] existe para os testes injetarem um mock.
  DioRestClient({required String baseUrl, Dio? dio})
    : _dio = dio ?? criarDio(BaseOptions(baseUrl: baseUrl));

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
    final resposta = await chamada;
    return RestResposta(status: resposta.statusCode ?? 0, dados: resposta.data);
  }
}
