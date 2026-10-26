import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

class _RestClientMock extends Mock implements RestClient {}

const _caminho = '/painel/lojista';

const _pedido = LojistaRequest(
  nomeFantasia: 'Mercado Bom Preço',
  nomeResponsavel: 'Ana Souza',
  whatsapp: '11987654321',
  cnpj: '77343168000124',
);

Map<String, Object?> _corpo() => {
  'id': '0192f0a1-6c2e-7b10-9f3a-1c2d3e4f5a01',
  'nomeFantasia': 'Mercado Bom Preço',
  'nomeResponsavel': 'Ana Souza',
  'email': 'ana@bompreco.com.br',
  'whatsapp': '+5511987654321',
  'cnpj': '77343168000124',
  'status': 'ATIVO',
  'criadoEm': '2026-10-18T13:00:00.000Z',
};

Map<String, Object?> _erro(
  String codigo,
  String mensagem, [
  Map<String, Object?>? detalhes,
]) => {
  'erro': {'codigo': codigo, 'mensagem': mensagem, 'detalhes': ?detalhes},
};

void main() {
  group('Funcionalidade: dados do lojista na API', () {
    late _RestClientMock client;
    late LojistaRepositoryApi repository;

    setUp(() {
      client = _RestClientMock();
      repository = LojistaRepositoryApi(client);
    });

    RestResposta resposta(int status, [Object? dados]) =>
        RestResposta(status: status, dados: dados);

    Falha falhaDe<T>(Either<Falha, T> resultado) =>
        (resultado as Failure<Falha, T>).falha;

    test('Cenário: Dado o lojista logado, quando obtenho, então recebo os dados dele', () async {
      when(() => client.get(_caminho))
          .thenAnswer((_) async => resposta(200, _corpo()));

      expect(
        await repository.obter(),
        Success<Falha, LojistaResponse>(lojistaFake),
      );
    });

    test('Cenário: Dado a sessão expirada (401), quando obtenho, então recebo FalhaApi NAO_AUTENTICADO', () async {
      when(() => client.get(_caminho)).thenAnswer(
        (_) async => resposta(
          401,
          _erro('NAO_AUTENTICADO', 'Faça login para continuar.'),
        ),
      );

      expect(
        falhaDe(await repository.obter()),
        const FalhaApi(
          codigo: 'NAO_AUTENTICADO',
          mensagem: 'Faça login para continuar.',
        ),
      );
    });

    test('Cenário: Dado a API sem conexão, quando obtenho, então recebo FalhaSemConexao', () async {
      when(() => client.get(_caminho)).thenThrow(const ErroSemConexao());

      expect(falhaDe(await repository.obter()), const FalhaSemConexao());
    });

    test('Cenário: Dado um corpo fora do formato, quando obtenho, então recebo FalhaInesperada', () async {
      when(() => client.get(_caminho))
          .thenAnswer((_) async => resposta(200, {'id': 'x'}));

      expect(falhaDe(await repository.obter()), isA<FalhaInesperada>());
    });

    test('Cenário: Dado a API aceitando (200), quando edito, então envio o PATCH com o corpo e recebo o lojista', () async {
      when(() => client.patch(_caminho, corpo: any(named: 'corpo')))
          .thenAnswer((_) async => resposta(200, _corpo()));

      expect(
        await repository.editar(_pedido),
        Success<Falha, LojistaResponse>(lojistaFake),
      );
      verify(() => client.patch(_caminho, corpo: _pedido.toJson())).called(1);
    });

    test('Cenário: Dado a conta desativada (403), quando edito, então recebo FalhaApi LOJISTA_DESATIVADO', () async {
      when(() => client.patch(_caminho, corpo: any(named: 'corpo'))).thenAnswer(
        (_) async => resposta(
          403,
          _erro(
            'LOJISTA_DESATIVADO',
            'Sua conta está desativada. O painel está disponível só para consulta.',
          ),
        ),
      );

      expect(
        falhaDe(await repository.editar(_pedido)),
        const FalhaApi(
          codigo: 'LOJISTA_DESATIVADO',
          mensagem: 'Sua conta está desativada. O painel está disponível só para consulta.',
        ),
      );
    });

    test('Cenário: Dado um WhatsApp inválido (400), quando edito, então o erro vai para o campo whatsapp', () async {
      when(() => client.patch(_caminho, corpo: any(named: 'corpo'))).thenAnswer(
        (_) async => resposta(
          400,
          _erro('VALIDACAO_INVALIDA', 'Dados inválidos.', {
            'campos': {
              'whatsapp': ['Informe um WhatsApp válido com DDD.'],
            },
          }),
        ),
      );

      expect(
        falhaDe(await repository.editar(_pedido)),
        const FalhaApi(
          codigo: 'VALIDACAO_INVALIDA',
          mensagem: 'Dados inválidos.',
          campos: {
            'whatsapp': ['Informe um WhatsApp válido com DDD.'],
          },
        ),
      );
    });
  });
}
