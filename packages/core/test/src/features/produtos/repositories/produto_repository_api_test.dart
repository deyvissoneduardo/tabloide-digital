import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../../responses/produto_response_test.dart' show corpoProduto;

class _RestClientMock extends Mock implements RestClient {}

const _filial = '0192f0b4-7d3f-7c21-8e4b-2d3e4f5a6b02';

const _caminho = '/painel/filiais/$_filial/produtos';

const _id = '0192f0d0-a062-7f54-9b7e-5a6b7c8d9e05';

const _pedido = ProdutoRequest(
  nome: 'Arroz Tipo 1',
  categoriaId: '0192f0c1-9f51-7e43-8a6d-4f5a6b7c8d04',
  precoPromocionalCentavos: 2199,
  precoOriginalCentavos: 2649,
);

Map<String, Object?> _pagina(int pagina, int quantidade, int total) => {
  'itens': [
    for (var i = 0; i < quantidade; i++) corpoProduto(id: 'p$pagina-$i'),
  ],
  'total': total,
  'pagina': pagina,
  'porPagina': 100,
};

void main() {
  group('Funcionalidade: produtos na API', () {
    late _RestClientMock client;
    late ProdutoRepositoryApi repository;

    setUp(() {
      client = _RestClientMock();
      repository = ProdutoRepositoryApi(client);
    });

    setUpAll(() => registerFallbackValue(MetodoEnvio.put));

    RestResposta resposta(int status, [Object? dados]) =>
        RestResposta(status: status, dados: dados);

    Falha falhaDe<T>(Either<Falha, T> resultado) =>
        (resultado as Failure<Falha, T>).falha;

    Map<String, Object> query(int pagina) => {
      'situacao': 'VIGENTE,AGENDADO',
      'pagina': pagina,
      'porPagina': 100,
    };

    test('Cenário: Dado uma página só, quando listo, então peço vigentes e agendados de 100 em 100', () async {
      when(() => client.get(_caminho, query: query(1)))
          .thenAnswer((_) async => resposta(200, _pagina(1, 1, 1)));

      final resultado = await repository.listar(_filial);

      expect(resultado.fold((_) => null, (l) => l.length), 1);
      verify(() => client.get(_caminho, query: query(1))).called(1);
    });

    test(
      'Cenário: Dado 150 produtos, quando listo, então junto as duas páginas',
      () async {
        when(() => client.get(_caminho, query: query(1)))
            .thenAnswer((_) async => resposta(200, _pagina(1, 100, 150)));
        when(() => client.get(_caminho, query: query(2)))
            .thenAnswer((_) async => resposta(200, _pagina(2, 50, 150)));

        final resultado = await repository.listar(_filial);

        expect(resultado.fold((_) => null, (l) => l.length), 150);
      },
    );

    test('Cenário: Dado falha na segunda página, quando listo, então recebo a falha', () async {
      when(() => client.get(_caminho, query: query(1)))
          .thenAnswer((_) async => resposta(200, _pagina(1, 100, 150)));
      when(() => client.get(_caminho, query: query(2)))
          .thenThrow(const ErroSemConexao());

      expect(
        falhaDe(await repository.listar(_filial)),
        const FalhaSemConexao(),
      );
    });

    test('Cenário: Dado uma página sem total, quando listo, então recebo FalhaInesperada', () async {
      when(() => client.get(_caminho, query: any(named: 'query')))
          .thenAnswer((_) async => resposta(200, {'itens': []}));

      expect(falhaDe(await repository.listar(_filial)), isA<FalhaInesperada>());
    });

    test('Cenário: Dado um produto existente, quando obtenho pelo id, então recebo o produto', () async {
      when(() => client.get('$_caminho/$_id'))
          .thenAnswer((_) async => resposta(200, corpoProduto()));

      expect(
        await repository.obter(_filial, _id),
        Success<Falha, ProdutoResponse>(produtoFake),
      );
    });

    test('Cenário: Dado um produto sem foto, quando cadastro, então faço POST JSON', () async {
      when(() => client.post(_caminho, corpo: _pedido.toJson()))
          .thenAnswer((_) async => resposta(201, corpoProduto()));

      expect(
        await repository.criar(_filial, _pedido),
        Success<Falha, ProdutoResponse>(produtoFake),
      );
      verifyNever(
        () => client.enviarArquivo(
          any(),
          campo: any(named: 'campo'),
          bytes: any(named: 'bytes'),
          nomeArquivo: any(named: 'nomeArquivo'),
          metodo: any(named: 'metodo'),
          campos: any(named: 'campos'),
        ),
      );
    });

    test('Cenário: Dado um produto com foto, quando cadastro, então faço POST multipart com a foto no campo "foto"', () async {
      when(
        () => client.enviarArquivo(
          _caminho,
          campo: 'foto',
          bytes: [1, 2, 3],
          nomeArquivo: 'arroz.jpg',
          metodo: MetodoEnvio.post,
          campos: _pedido.toCampos(),
        ),
      ).thenAnswer((_) async => resposta(201, corpoProduto()));

      expect(
        await repository.criar(
          _filial,
          _pedido,
          foto: (bytes: [1, 2, 3], nome: 'arroz.jpg'),
        ),
        Success<Falha, ProdutoResponse>(produtoFake),
      );
    });

    test('Cenário: Dado preço original menor (422), quando cadastro, então recebo FalhaApi PRECO_ORIGINAL_INVALIDO (RN21)', () async {
      when(() => client.post(_caminho, corpo: any(named: 'corpo'))).thenAnswer(
        (_) async => resposta(422, {
          'erro': {
            'codigo': 'PRECO_ORIGINAL_INVALIDO',
            'mensagem':
                'O preço original precisa ser maior que o preço promocional.',
            'detalhes': {
              'precoPromocionalCentavos': 1000,
              'precoOriginalCentavos': 900,
            },
          },
        }),
      );

      final falha = falhaDe(await repository.criar(_filial, _pedido));

      expect((falha as FalhaApi).codigo, 'PRECO_ORIGINAL_INVALIDO');
      expect(falha.detalhes['precoOriginalCentavos'], 900);
    });

    test('Cenário: Dado só o preço alterado, quando edito, então faço PATCH só com o que mudou', () async {
      final pedido = EditarProdutoRequest.entre(
        produtoFake,
        ProdutoRequest(
          nome: 'Arroz Tipo 1',
          categoriaId: produtoFake.categoria.id,
          precoPromocionalCentavos: 1999,
          precoOriginalCentavos: 2649,
          quantidade: '5kg',
          dataInicio: DateTime(2026, 10, 18),
          dataLimite: DateTime(2026, 10, 25),
        ),
      );
      when(
        () => client.patch(
          '$_caminho/$_id',
          corpo: {'precoPromocionalCentavos': 1999, 'observacao': null},
        ),
      ).thenAnswer((_) async => resposta(200, corpoProduto()));

      expect((await repository.editar(_filial, _id, pedido)).isSuccess, isTrue);
    });

    test('Cenário: Dado um produto vencido (409), quando edito, então recebo FalhaApi ITEM_NAO_EDITAVEL (RN26)', () async {
      when(() => client.patch('$_caminho/$_id', corpo: any(named: 'corpo')))
          .thenAnswer(
            (_) async => resposta(409, {
              'erro': {
                'codigo': 'ITEM_NAO_EDITAVEL',
                'mensagem':
                    'Produtos vencidos ou excluídos não podem ser editados. '
                    'Cadastre um novo produto.',
              },
            }),
          );

      final falha = falhaDe(
        await repository.editar(
          _filial,
          _id,
          EditarProdutoRequest.entre(produtoFake, _pedido),
        ),
      );

      expect((falha as FalhaApi).codigo, 'ITEM_NAO_EDITAVEL');
    });

    test('Cenário: Dado uma foto nova, quando troco, então faço PUT multipart em /foto', () async {
      when(
        () => client.enviarArquivo(
          '$_caminho/$_id/foto',
          campo: 'foto',
          bytes: [9],
          nomeArquivo: 'nova.png',
          metodo: any(named: 'metodo'),
          campos: any(named: 'campos'),
        ),
      ).thenAnswer((_) async => resposta(200, corpoProduto()));

      expect(
        (await repository.trocarFoto(_filial, _id, (
          bytes: [9],
          nome: 'nova.png',
        ))).isSuccess,
        isTrue,
      );
    });

    test('Cenário: Dado um produto com foto, quando removo a foto, então faço DELETE em /foto e recebo o produto sem foto', () async {
      when(() => client.delete('$_caminho/$_id/foto'))
          .thenAnswer((_) async => resposta(200, corpoProduto(urlFoto: null)));

      final resultado = await repository.removerFoto(_filial, _id);

      expect(resultado.fold((_) => 'falhou', (p) => p.urlFoto), isNull);
    });

    test(
      'Cenário: Dado um produto, quando excluo (204), então recebo Nada',
      () async {
        when(() => client.delete('$_caminho/$_id'))
            .thenAnswer((_) async => resposta(204));

        expect(
          await repository.excluir(_filial, _id),
          const Success<Falha, Nada>(Nada()),
        );
      },
    );
  });
}
