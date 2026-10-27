import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/src/http/autenticacao_interceptor.dart';
import 'package:tabloide_core/src/http/dio_rest_client.dart';
import 'package:tabloide_core/src/http/rest_client.dart';

final class _Adaptador implements HttpClientAdapter {
  _Adaptador(this.responder);

  final ResponseBody Function(RequestOptions options) responder;

  final pedidos = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    pedidos.add(options);
    return responder(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object corpo, int status) => ResponseBody.fromBytes(
  utf8.encode(jsonEncode(corpo)),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

void main() {
  group('Funcionalidade: Download de arquivo pelo RestClient', () {
    late _Adaptador adaptador;
    String? token;

    DioRestClient cliente(ResponseBody Function(RequestOptions) responder) {
      adaptador = _Adaptador(responder);
      final dio = Dio(BaseOptions(baseUrl: 'http://api'))
        ..httpClientAdapter = adaptador
        ..interceptors.add(AutenticacaoInterceptor(() => token));
      return DioRestClient(baseUrl: 'http://api', dio: dio);
    }

    setUp(() => token = null);

    test('Cenário: Dado um 200 com bytes, quando baixo, então dados é Uint8List com os mesmos bytes', () async {
      final png = [137, 80, 78, 71, 0, 255];
      final resposta = await cliente(
        (_) => ResponseBody.fromBytes(
          png,
          200,
          headers: {
            Headers.contentTypeHeader: ['image/png'],
          },
        ),
      ).baixar('/qrcode', query: {'formato': 'png'});

      expect(resposta.status, 200);
      expect(resposta.dados, isA<Uint8List>());
      expect(resposta.dados, png);
      expect(adaptador.pedidos.single.queryParameters, {'formato': 'png'});
    });

    test('Cenário: Dado um 404 com JSON de erro, quando baixo, então dados é o mapa do erro', () async {
      final erro = {
        'erro': {
          'codigo': 'RECURSO_NAO_ENCONTRADO',
          'mensagem': 'Recurso não encontrado.',
        },
      };
      final resposta = await cliente((_) => _json(erro, 404)).baixar('/x');

      expect(resposta.status, 404);
      expect(resposta.dados, erro);
    });

    test(
      'Cenário: Dado um 500 sem corpo, quando baixo, então dados é null',
      () async {
        final resposta = await cliente(
          (_) => ResponseBody.fromBytes(const [], 500),
        ).baixar('/x');

        expect(resposta.status, 500);
        expect(resposta.dados, isNull);
      },
    );

    test('Cenário: Dado uma sessão com token, quando baixo, então o header Authorization é enviado', () async {
      token = 'eyJ.token';
      await cliente((_) => ResponseBody.fromBytes(const [1], 200)).baixar('/x');

      expect(
        adaptador.pedidos.single.headers['Authorization'],
        'Bearer eyJ.token',
      );
    });

    test(
      'Cenário: Dado sem conexão, quando baixo, então lança ErroSemConexao',
      () {
        final rest = cliente(
          (options) => throw DioException.connectionError(
            requestOptions: options,
            reason: 'offline',
          ),
        );

        expect(rest.baixar('/x'), throwsA(isA<ErroSemConexao>()));
      },
    );
  });
}
