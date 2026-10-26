import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_core/src/http/dio_rest_client.dart';
import 'package:tabloide_core/src/http/rest_client.dart';

class _DioMock extends Mock implements Dio {}

Response<Object?> _resposta(int status, Object? dados) =>
    Response(requestOptions: RequestOptions(), statusCode: status, data: dados);

void main() {
  group('Funcionalidade: RestClient sobre o Dio', () {
    group('Cenário: Dado um DioRestClient com Dio mockado', () {
      late _DioMock dio;
      late DioRestClient cliente;
      setUp(() {
        dio = _DioMock();
        cliente = DioRestClient(baseUrl: 'http://api', dio: dio);
      });

      test('Quando faço GET com query, então repasso a query e converto status e dados', () async {
        when(() => dio.get<Object?>('/itens', queryParameters: {'pagina': 1}))
            .thenAnswer((_) async => _resposta(200, {'total': 0}));

        final resposta = await cliente.get('/itens', query: {'pagina': 1});

        expect(resposta.status, 200);
        expect(resposta.dados, {'total': 0});
      });

      test('Quando faço POST, então repasso o corpo', () async {
        when(() => dio.post<Object?>('/itens', data: {'nome': 'a'}))
            .thenAnswer((_) async => _resposta(201, null));

        final resposta = await cliente.post('/itens', corpo: {'nome': 'a'});

        expect(resposta.status, 201);
        verify(() => dio.post<Object?>('/itens', data: {'nome': 'a'}))
            .called(1);
      });

      test('Quando faço PATCH, PUT e DELETE, então cada um chama o método certo do Dio', () async {
        when(() => dio.patch<Object?>('/a', data: 1))
            .thenAnswer((_) async => _resposta(200, null));
        when(() => dio.put<Object?>('/a', data: 2))
            .thenAnswer((_) async => _resposta(200, null));
        when(() => dio.delete<Object?>('/a'))
            .thenAnswer((_) async => _resposta(204, null));

        await cliente.patch('/a', corpo: 1);
        await cliente.put('/a', corpo: 2);
        final excluido = await cliente.delete('/a');

        expect(excluido.status, 204);
        verify(() => dio.patch<Object?>('/a', data: 1)).called(1);
        verify(() => dio.put<Object?>('/a', data: 2)).called(1);
      });

      test('Quando envio um arquivo, então faço PUT multipart com o campo, o nome e o tipo do arquivo', () async {
        when(() => dio.put<Object?>('/logo', data: any(named: 'data')))
            .thenAnswer((_) async => _resposta(200, {'ok': true}));

        final resposta = await cliente.enviarArquivo(
          '/logo',
          campo: 'imagem',
          bytes: [1, 2, 3],
          nomeArquivo: 'logo.png',
        );

        expect(resposta.status, 200);
        final dados =
            verify(
                  () => dio.put<Object?>(
                    '/logo',
                    data: captureAny(named: 'data'),
                  ),
                ).captured.single
                as FormData;
        final MapEntry(key: campo, value: arquivo) = dados.files.single;
        expect(campo, 'imagem');
        expect(arquivo.filename, 'logo.png');
        expect(arquivo.length, 3);
        expect(arquivo.contentType?.mimeType, 'image/png');
      });

      test('Quando envio um arquivo por POST com campos, então faço POST multipart com os campos e o arquivo', () async {
        when(() => dio.post<Object?>('/panfletos', data: any(named: 'data')))
            .thenAnswer((_) async => _resposta(201, {'ok': true}));

        final resposta = await cliente.enviarArquivo(
          '/panfletos',
          campo: 'imagem',
          bytes: [1, 2],
          nomeArquivo: 'panfleto.jpg',
          metodo: MetodoEnvio.post,
          campos: {'dataLimite': '2026-12-31'},
        );

        expect(resposta.status, 201);
        final dados =
            verify(
                  () => dio.post<Object?>(
                    '/panfletos',
                    data: captureAny(named: 'data'),
                  ),
                ).captured.single
                as FormData;
        expect(dados.fields.map((c) => (c.key, c.value)), [
          ('dataLimite', '2026-12-31'),
        ]);
        final MapEntry(key: campo, value: arquivo) = dados.files.single;
        expect(campo, 'imagem');
        expect(arquivo.filename, 'panfleto.jpg');
        expect(arquivo.contentType?.mimeType, 'image/jpeg');
        verifyNever(() => dio.put<Object?>(any(), data: any(named: 'data')));
      });

      test('Quando a API responde 401, então devolvo a resposta com o corpo de erro em vez de lançar', () async {
        when(() => dio.post<Object?>('/auth/login', data: any(named: 'data')))
            .thenAnswer(
              (_) async => throw DioException.badResponse(
                statusCode: 401,
                requestOptions: RequestOptions(),
                response: _resposta(401, {
                  'erro': {'codigo': 'CREDENCIAIS_INVALIDAS'},
                }),
              ),
            );

        final resposta = await cliente.post('/auth/login', corpo: {});

        expect(resposta.status, 401);
        expect(resposta.dados, {
          'erro': {'codigo': 'CREDENCIAIS_INVALIDAS'},
        });
      });

      for (final tipo in [
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        test(
          'Quando o Dio falha com ${tipo.name}, então lanço ErroSemConexao',
          () {
            when(() => dio.get<Object?>('/a')).thenAnswer(
              (_) async => throw DioException(
                requestOptions: RequestOptions(),
                type: tipo,
              ),
            );

            expect(cliente.get('/a'), throwsA(isA<ErroSemConexao>()));
          },
        );
      }

      test(
        'Quando o Dio falha por outro motivo, então a exceção original segue',
        () {
          when(() => dio.get<Object?>('/a')).thenAnswer(
            (_) async => throw DioException(
              requestOptions: RequestOptions(),
              type: DioExceptionType.cancel,
            ),
          );

          expect(cliente.get('/a'), throwsA(isA<DioException>()));
        },
      );

      test('Quando o Dio responde sem status, então o status vira 0', () async {
        when(
          () => dio.get<Object?>('/a'),
        ).thenAnswer((_) async => Response(requestOptions: RequestOptions()));

        expect((await cliente.get('/a')).status, 0);
      });
    });

    group('Cenário: Dado um DioRestClient sem Dio injetado (VM de teste)', () {
      test(
        'Quando crio o cliente, então ele usa a fábrica nativa sem erro',
        () {
          expect(() => DioRestClient(baseUrl: 'http://api'), returnsNormally);
        },
      );
    });
  });
}
