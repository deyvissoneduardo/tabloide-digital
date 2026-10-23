import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_core/tabloide_core.dart';

import '../../../responses/login_response_test.dart' show corpoLogin;

class _RestClientMock extends Mock implements RestClient {}

const _pedido = LoginRequest(email: 'teste01@gmail.com', senha: 'Teste1234');

void main() {
  group('Funcionalidade: login na API', () {
    late _RestClientMock client;
    late AuthRepositoryApi repository;

    setUp(() {
      client = _RestClientMock();
      repository = AuthRepositoryApi(client);
    });

    void responder(int status, Object? dados) => when(
      () => client.post('/auth/login', corpo: any(named: 'corpo')),
    ).thenAnswer((_) async => RestResposta(status: status, dados: dados));

    test('Cenário: Dado credenciais válidas, quando entro, então envio e-mail e senha e recebo a sessão', () async {
      responder(201, corpoLogin());

      final resultado = await repository.entrar(_pedido);

      expect(
        resultado,
        Success<Falha, LoginResponse>(LoginResponse.fromJson(corpoLogin())),
      );
      verify(
        () => client.post(
          '/auth/login',
          corpo: {'email': 'teste01@gmail.com', 'senha': 'Teste1234'},
        ),
      ).called(1);
    });

    for (final (status, codigo, mensagem) in [
      (401, 'CREDENCIAIS_INVALIDAS', 'E-mail ou senha incorretos.'),
      (
        429,
        'MUITAS_TENTATIVAS',
        'Muitas tentativas. Aguarde e tente novamente.',
      ),
    ]) {
      test(
        'Cenário: Dado a API respondendo $status $codigo, quando entro, então recebo FalhaApi com a mensagem da API',
        () async {
          responder(status, {
            'erro': {'codigo': codigo, 'mensagem': mensagem},
          });

          final resultado = await repository.entrar(_pedido);

          expect(
            resultado,
            Failure<Falha, LoginResponse>(
              FalhaApi(codigo: codigo, mensagem: mensagem),
            ),
          );
        },
      );
    }

    test('Cenário: Dado um erro sem corpo no formato da API, quando entro, então recebo FalhaInesperada', () async {
      responder(500, '<html>');

      final resultado = await repository.entrar(_pedido);

      expect(
        resultado,
        isA<Failure<Falha, LoginResponse>>().having(
          (f) => f.falha,
          'falha',
          isA<FalhaInesperada>(),
        ),
      );
    });

    test('Cenário: Dado um 201 com corpo inválido, quando entro, então recebo FalhaInesperada', () async {
      responder(201, {'token': 'x'});

      final resultado = await repository.entrar(_pedido);

      expect(
        (resultado as Failure<Falha, LoginResponse>).falha,
        isA<FalhaInesperada>(),
      );
    });

    test('Cenário: Dado o servidor fora do ar, quando entro, então recebo FalhaSemConexao', () async {
      when(() => client.post('/auth/login', corpo: any(named: 'corpo')))
          .thenAnswer((_) async => throw const ErroSemConexao());

      expect(
        await repository.entrar(_pedido),
        const Failure<Falha, LoginResponse>(FalhaSemConexao()),
      );
    });
  });
}
