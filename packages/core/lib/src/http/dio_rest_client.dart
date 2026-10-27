import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tabloide_core/src/http/autenticacao_interceptor.dart';
import 'package:tabloide_core/src/http/dio_factory.dart';
import 'package:tabloide_core/src/http/log_api_interceptor.dart';
import 'package:tabloide_core/src/http/rest_client.dart';

final class DioRestClient implements RestClient {
  DioRestClient({required String baseUrl, Dio? dio, String? Function()? token})
    : _dio =
          dio ??
          (criarDio(BaseOptions(baseUrl: baseUrl))
            ..interceptors.addAll([
              if (token != null) AutenticacaoInterceptor(token),
              if (kDebugMode) LogApiInterceptor(),
            ]));

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

  @override
  Future<RestResposta> baixar(String caminho, {Map<String, dynamic>? query}) =>
      _converter(
        _dio.get<List<int>>(
          caminho,
          queryParameters: query,
          options: Options(responseType: ResponseType.bytes),
        ),
        binario: true,
      );

  @override
  Future<RestResposta> enviarArquivo(
    String caminho, {
    required String campo,
    required List<int> bytes,
    required String nomeArquivo,
    MetodoEnvio metodo = MetodoEnvio.put,
    Map<String, String> campos = const {},
  }) {
    final dados = FormData.fromMap({
      ...campos,
      campo: MultipartFile.fromBytes(
        bytes,
        filename: nomeArquivo,
        contentType: MultipartFile.lookupMediaType(nomeArquivo),
      ),
    });
    return _converter(switch (metodo) {
      MetodoEnvio.post => _dio.post<Object?>(caminho, data: dados),
      MetodoEnvio.put => _dio.put<Object?>(caminho, data: dados),
    });
  }

  Future<RestResposta> _converter(
    Future<Response<Object?>> chamada, {
    bool binario = false,
  }) async {
    try {
      return _resposta(await chamada, binario: binario);
    } on DioException catch (erro) {
      if (erro.response case final resposta?
          when erro.type == DioExceptionType.badResponse) {
        return _resposta(resposta, binario: binario);
      }
      if (_semConexao.contains(erro.type)) throw const ErroSemConexao();
      rethrow;
    }
  }

  RestResposta _resposta(Response<Object?> resposta, {bool binario = false}) {
    final status = resposta.statusCode ?? 0;
    if (!binario) return RestResposta(status: status, dados: resposta.data);
    final bytes = switch (resposta.data) {
      final List<int> bytes => bytes,
      _ => null,
    };
    if (status >= 200 && status < 300) {
      return RestResposta(
        status: status,
        dados: bytes == null ? null : Uint8List.fromList(bytes),
      );
    }
    return RestResposta(status: status, dados: _jsonDe(bytes));
  }

  Object? _jsonDe(List<int>? bytes) {
    if (bytes == null || bytes.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(bytes));
    } on FormatException {
      return null;
    }
  }

  static const _semConexao = {
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
  };
}
