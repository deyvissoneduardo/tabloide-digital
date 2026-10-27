import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_core/tabloide_core.dart';

import '../../../responses/estrutura_response_test.dart' show corpoEstrutura;

class _RestClientMock extends Mock implements RestClient {}

const _filial = '0192f0b4-7d3f-7c21-8e4b-2d3e4f5a6b02';

const _caminho = '/painel/filiais/$_filial/estrutura';

void main() {
  group('Funcionalidade: estrutura da filial na API', () {
    late _RestClientMock client;
    late EstruturaRepositoryApi repository;

    setUp(() {
      client = _RestClientMock();
      repository = EstruturaRepositoryApi(client);
    });

    Falha falhaDe<T>(Either<Falha, T> resultado) =>
        (resultado as Failure<Falha, T>).falha;

    test('Cenário: Dado a filial, quando obtenho, então faço GET no caminho da estrutura e leio as categorias', () async {
      when(() => client.get(_caminho)).thenAnswer(
        (_) async => RestResposta(status: 200, dados: corpoEstrutura()),
      );

      final resultado = await repository.obter(_filial);

      expect(
        resultado.fold((_) => null, (e) => e.categorias.map((c) => c.nome)),
        ['Hortifrúti', 'Mercearia', 'Bebidas'],
      );
    });

    test('Cenário: Dado uma nova ordem, quando salvo, então faço PUT com o corpo do pedido e leio a resposta', () async {
      const pedido = EstruturaRequest([
        CategoriaOrdenada(id: 'c2', produtos: ['p3']),
      ]);
      when(() => client.put(_caminho, corpo: any(named: 'corpo'))).thenAnswer(
        (_) async => RestResposta(status: 200, dados: corpoEstrutura()),
      );

      final resultado = await repository.salvar(_filial, pedido);

      expect(resultado.isSuccess, isTrue);
      expect(
        verify(() => client.put(_caminho, corpo: captureAny(named: 'corpo')))
            .captured
            .single,
        pedido.toJson(),
      );
    });

    test('Cenário: Dado 422 ESTRUTURA_INVALIDA, quando salvo, então recebo FalhaApi com detalhes.problemas', () async {
      when(() => client.put(_caminho, corpo: any(named: 'corpo'))).thenAnswer(
        (_) async => const RestResposta(
          status: 422,
          dados: {
            'erro': {
              'codigo': 'ESTRUTURA_INVALIDA',
              'mensagem': 'A ordem enviada não corresponde às categorias e produtos desta filial. Recarregue e tente de novo.',
              'detalhes': {
                'problemas': [
                  {'tipo': 'PRODUTO_DESCONHECIDO', 'id': 'p9'},
                ],
              },
            },
          },
        ),
      );

      final falha = falhaDe(
        await repository.salvar(_filial, const EstruturaRequest([])),
      );

      expect(
        falha,
        isA<FalhaApi>()
            .having((f) => f.codigo, 'codigo', 'ESTRUTURA_INVALIDA')
            .having((f) => f.detalhes['problemas'], 'problemas', [
              {'tipo': 'PRODUTO_DESCONHECIDO', 'id': 'p9'},
            ]),
      );
    });

    test('Cenário: Dado 403 LOJISTA_DESATIVADO, quando salvo, então recebo FalhaApi com o código', () async {
      when(() => client.put(_caminho, corpo: any(named: 'corpo'))).thenAnswer(
        (_) async => const RestResposta(
          status: 403,
          dados: {
            'erro': {
              'codigo': 'LOJISTA_DESATIVADO',
              'mensagem': 'Conta desativada.',
            },
          },
        ),
      );

      expect(
        falhaDe(await repository.salvar(_filial, const EstruturaRequest([]))),
        isA<FalhaApi>().having((f) => f.codigo, 'codigo', 'LOJISTA_DESATIVADO'),
      );
    });

    test(
      'Cenário: Dado sem conexão, quando obtenho, então recebo FalhaSemConexao',
      () async {
        when(() => client.get(_caminho)).thenThrow(const ErroSemConexao());

        expect(
          falhaDe(await repository.obter(_filial)),
          const FalhaSemConexao(),
        );
      },
    );

    test('Cenário: Dado um 200 fora do formato, quando obtenho, então recebo FalhaInesperada', () async {
      when(() => client.get(_caminho)).thenAnswer(
        (_) async => const RestResposta(status: 200, dados: {'x': 1}),
      );

      expect(falhaDe(await repository.obter(_filial)), isA<FalhaInesperada>());
    });
  });
}
