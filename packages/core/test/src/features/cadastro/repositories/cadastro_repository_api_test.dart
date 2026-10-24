import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_core/tabloide_core.dart';

import '../../../responses/login_response_test.dart' show corpoLogin;

class _RestClientMock extends Mock implements RestClient {}

const _pedido = CadastroRequest(
  nomeFantasia: 'Mercado Bom Preço',
  nomeResponsavel: 'Teste 02',
  email: 'teste01@gmail.com',
  senha: 'Teste1234',
  whatsapp: '11987654321',
  cnpj: '11222333000181',
);

void main() {
  group('Funcionalidade: cadastro na API', () {
    late _RestClientMock client;
    late CadastroRepositoryApi repository;

    setUp(() {
      client = _RestClientMock();
      repository = CadastroRepositoryApi(client);
    });

    void responder(int status, Object? dados) => when(
      () => client.post('/auth/cadastro', corpo: any(named: 'corpo')),
    ).thenAnswer((_) async => RestResposta(status: status, dados: dados));

    Falha falhaDe(Either<Falha, CadastroResponse> resultado) =>
        (resultado as Failure<Falha, CadastroResponse>).falha;

    for (final status in [200, 201]) {
      test(
        'Cenário: Dado a API respondendo $status, quando cadastro, então envio os dados e recebo a conta com a sessão',
        () async {
          responder(status, corpoLogin());

          final resultado = await repository.cadastrar(_pedido);

          expect(
            resultado,
            Success<Falha, CadastroResponse>(
              CadastroResponse.fromJson(corpoLogin()),
            ),
          );
          verify(() => client.post('/auth/cadastro', corpo: _pedido.toJson()))
              .called(1);
        },
      );
    }

    test('Cenário: Dado a API respondendo 400 com detalhes por campo, quando cadastro, então recebo FalhaApi com os erros de cada campo', () async {
      responder(400, {
        'erro': {
          'codigo': 'VALIDACAO_INVALIDA',
          'mensagem': 'Dados inválidos.',
          'detalhes': {
            'campos': {
              'senha': [
                'A senha precisa ter de 8 a 128 caracteres, com ao menos uma letra e um número.',
              ],
              'whatsapp': ['Informe um WhatsApp válido com DDD.'],
            },
          },
        },
      });

      expect(
        falhaDe(await repository.cadastrar(_pedido)),
        const FalhaApi(
          codigo: 'VALIDACAO_INVALIDA',
          mensagem: 'Dados inválidos.',
          campos: {
            'senha': [
              'A senha precisa ter de 8 a 128 caracteres, com ao menos uma letra e um número.',
            ],
            'whatsapp': ['Informe um WhatsApp válido com DDD.'],
          },
        ),
      );
    });

    test('Cenário: Dado a API respondendo 409 EMAIL_JA_CADASTRADO, quando cadastro, então o erro vira do campo e-mail (RN37)', () async {
      responder(409, {
        'erro': {
          'codigo': 'EMAIL_JA_CADASTRADO',
          'mensagem': 'Este e-mail já está cadastrado.',
        },
      });

      expect(
        falhaDe(await repository.cadastrar(_pedido)),
        const FalhaApi(
          codigo: 'EMAIL_JA_CADASTRADO',
          mensagem: 'Este e-mail já está cadastrado.',
          campos: {
            'email': ['Este e-mail já está cadastrado.'],
          },
        ),
      );
    });

    test('Cenário: Dado um erro da API sem detalhes, quando cadastro, então recebo FalhaApi sem erros de campo', () async {
      responder(429, {
        'erro': {'codigo': 'MUITAS_TENTATIVAS', 'mensagem': 'Aguarde.'},
      });

      expect(
        falhaDe(await repository.cadastrar(_pedido)),
        const FalhaApi(codigo: 'MUITAS_TENTATIVAS', mensagem: 'Aguarde.'),
      );
    });

    test('Cenário: Dado detalhes fora do formato, quando cadastro, então ignoro o que não for lista de texto', () async {
      responder(400, {
        'erro': {
          'codigo': 'VALIDACAO_INVALIDA',
          'mensagem': 'Dados inválidos.',
          'detalhes': {
            'campos': {
              'cnpj': ['CNPJ inválido.', 7],
              'email': 'texto solto',
            },
          },
        },
      });

      expect(
        (falhaDe(await repository.cadastrar(_pedido)) as FalhaApi).campos,
        {
          'cnpj': ['CNPJ inválido.'],
        },
      );
    });

    test('Cenário: Dado um erro sem corpo no formato da API, quando cadastro, então recebo FalhaInesperada', () async {
      responder(500, '<html>');

      expect(
        falhaDe(await repository.cadastrar(_pedido)),
        isA<FalhaInesperada>(),
      );
    });

    test('Cenário: Dado um 201 com corpo inválido, quando cadastro, então recebo FalhaInesperada', () async {
      responder(201, {'token': 'x'});

      expect(
        falhaDe(await repository.cadastrar(_pedido)),
        isA<FalhaInesperada>(),
      );
    });

    test('Cenário: Dado o servidor fora do ar, quando cadastro, então recebo FalhaSemConexao', () async {
      when(() => client.post('/auth/cadastro', corpo: any(named: 'corpo')))
          .thenAnswer((_) async => throw const ErroSemConexao());

      expect(
        falhaDe(await repository.cadastrar(_pedido)),
        const FalhaSemConexao(),
      );
    });
  });
}
