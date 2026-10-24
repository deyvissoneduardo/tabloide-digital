import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/src/http/log_api_interceptor.dart';

const _amarelo = '\x1B[33m';
const _vermelho = '\x1B[31m';

final class _Adaptador implements HttpClientAdapter {
  _Adaptador({this.status = 200, this.corpo, this.semConexao = false});

  final int status;
  final Object? corpo;
  final bool semConexao;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (semConexao) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'sem rede',
      );
    }
    return ResponseBody.fromString(
      jsonEncode(corpo),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('Funcionalidade: log das chamadas à API no debug', () {
    late List<String> linhas;

    Dio dio(_Adaptador adaptador) =>
        Dio(BaseOptions(baseUrl: 'https://api.teste/v1'))
          ..httpClientAdapter = adaptador
          ..interceptors.add(LogApiInterceptor(escrever: linhas.add));

    List<String> bloco(String titulo) {
      final inicio = linhas.indexWhere(
        (l) => l.contains('┌') && l.contains(titulo),
      );
      expect(inicio, isNot(-1), reason: 'bloco $titulo não encontrado');
      final fim = linhas.indexWhere((l) => l.contains('└'), inicio);
      return linhas.sublist(inicio, fim + 1);
    }

    setUp(() => linhas = []);

    test('Cenário: Dado um login aceito, quando chamo a API, então request e response saem em blocos amarelos separados, sem senha nem token', () async {
      await dio(
        _Adaptador(
          corpo: {
            'token': 'eyJ.segredo',
            'lojista': {'id': '1'},
          },
        ),
      ).post<Object?>(
        '/auth/login',
        data: {'email': 'a@b.com', 'senha': 'Teste1234'},
      );

      final request = bloco('REQUEST');
      final response = bloco('RESPONSE 200');
      expect(request, everyElement(startsWith(_amarelo)));
      expect(response, everyElement(startsWith(_amarelo)));
      expect(request.join(), contains('POST https://api.teste/v1/auth/login'));
      expect(request.join(), contains('a@b.com'));
      expect(response.join(), contains('"id": "1"'));
      expect(linhas.join(), isNot(contains('Teste1234')));
      expect(linhas.join(), isNot(contains('eyJ.segredo')));
      expect(linhas.join(), contains('***'));
    });

    test('Cenário: Dado a API recusando (401), quando chamo, então o request fica amarelo e o response vermelho com o erro da API', () async {
      await expectLater(
        dio(
          _Adaptador(
            status: 401,
            corpo: {
              'erro': {'codigo': 'CREDENCIAIS_INVALIDAS'},
            },
          ),
        ).post<Object?>('/auth/login', data: {}),
        throwsA(isA<DioException>()),
      );

      expect(bloco('REQUEST'), everyElement(startsWith(_amarelo)));
      final response = bloco('RESPONSE 401');
      expect(response, everyElement(startsWith(_vermelho)));
      expect(response.join(), contains('CREDENCIAIS_INVALIDAS'));
    });

    test('Cenário: Dado o servidor fora do ar, quando chamo, então o response sai vermelho com o tipo do erro', () async {
      await expectLater(
        dio(_Adaptador(semConexao: true)).get<Object?>('/a'),
        throwsA(isA<DioException>()),
      );

      final response = bloco('RESPONSE connectionError');
      expect(response, everyElement(startsWith(_vermelho)));
      expect(response.join(), contains('GET https://api.teste/v1/a'));
    });

    test('Cenário: Dado um header Authorization, quando chamo, então o valor não aparece no log', () async {
      await dio(_Adaptador(corpo: {})).get<Object?>(
        '/a',
        options: Options(headers: {'Authorization': 'Bearer eyJ.segredo'}),
      );

      expect(linhas.join(), isNot(contains('eyJ.segredo')));
    });
  });
}
