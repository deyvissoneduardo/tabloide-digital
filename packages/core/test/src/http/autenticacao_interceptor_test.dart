import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/src/http/autenticacao_interceptor.dart';

final class _AdaptadorFake implements HttpClientAdapter {
  final cabecalhos = <Map<String, dynamic>>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    cabecalhos.add({...options.headers});
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('Funcionalidade: token nas chamadas à API', () {
    late _AdaptadorFake adaptador;
    String? token;

    setUp(() {
      adaptador = _AdaptadorFake();
      token = null;
    });

    Dio dio() => Dio(BaseOptions(baseUrl: 'http://api'))
      ..httpClientAdapter = adaptador
      ..interceptors.add(AutenticacaoInterceptor(() => token));

    test('Cenário: Dado uma sessão com token, quando chamo a API, então envio Authorization Bearer', () async {
      token = 'eyJ.token';

      await dio().get<Object?>('/painel/filiais');

      expect(adaptador.cabecalhos.single['Authorization'], 'Bearer eyJ.token');
    });

    test('Cenário: Dado nenhuma sessão, quando chamo a API, então não envio Authorization', () async {
      await dio().get<Object?>('/auth/login');

      expect(adaptador.cabecalhos.single.containsKey('Authorization'), isFalse);
    });

    test('Cenário: Dado o token trocado entre chamadas, quando chamo de novo, então envio o token atual', () async {
      final cliente = dio();
      token = 'antigo';
      await cliente.get<Object?>('/a');
      token = 'novo';
      await cliente.get<Object?>('/a');

      expect(adaptador.cabecalhos.last['Authorization'], 'Bearer novo');
    });
  });
}
