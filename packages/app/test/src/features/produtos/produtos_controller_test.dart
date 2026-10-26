import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

ProdutoResponse _produto(
  String id,
  String nome,
  CategoriaDoProduto categoria,
) => ProdutoResponse(
  id: id,
  filialId: produtoFake.filialId,
  categoria: categoria,
  nome: nome,
  precoPromocionalCentavos: 100,
  vigencia: produtoFake.vigencia,
  criadoEm: produtoFake.criadoEm,
  atualizadoEm: produtoFake.atualizadoEm,
);

void main() {
  group('Funcionalidade: lista de produtos no app', () {
    const mercearia = CategoriaDoProduto(id: 'c1', nome: 'Mercearia');
    const bebidas = CategoriaDoProduto(id: 'c2', nome: 'Bebidas');

    test('Cenário: Dado produtos de duas categorias, quando carrego, então agrupo por categoria e ordeno tudo alfabeticamente (RN30)', () async {
      final controller = produtosControllerDeTeste(
        repository: ProdutoRepositoryFake(
          produtos: [
            _produto('1', 'Feijão', mercearia),
            _produto('2', 'Suco', bebidas),
            _produto('3', 'arroz', mercearia),
            _produto('4', 'Água', bebidas),
          ],
        ),
      );

      await controller.carregar(produtoFake.filialId);

      expect(
        [
          for (final (:categoria, :produtos) in controller.grupos)
            '${categoria.nome}: ${produtos.map((p) => p.nome).join(', ')}',
        ],
        ['Bebidas: Suco, Água', 'Mercearia: arroz, Feijão'],
      );
    });

    test('Cenário: Dado falha na API, quando carrego, então o estado guarda a falha', () async {
      final controller = produtosControllerDeTeste(
        repository: ProdutoRepositoryFake(
          falhaSimulada: const FalhaSemConexao(),
        ),
      );

      await controller.carregar('f1');

      expect(controller.estado, isA<ProdutosComFalha>());
      expect(controller.grupos, isEmpty);
    });

    test('Cenário: Dado um produto salvo de outra filial, quando recebo, então ignoro', () async {
      final controller = produtosControllerDeTeste();
      await controller.carregar(produtoFake.filialId);

      controller.salvo(
        ProdutoResponse(
          id: 'outro',
          filialId: 'outra-filial',
          categoria: produtoFake.categoria,
          nome: 'Fora',
          precoPromocionalCentavos: 1,
          vigencia: produtoFake.vigencia,
          criadoEm: produtoFake.criadoEm,
          atualizadoEm: produtoFake.atualizadoEm,
        ),
      );

      expect(controller.produtos, [produtoFake]);
    });

    test('Cenário: Dado um produto novo e um editado, quando salvos, então a lista acrescenta e substitui', () async {
      final controller = produtosControllerDeTeste();
      await controller.carregar(produtoFake.filialId);
      final novo = _produto('novo', 'Biscoito', mercearia);
      final editado = _produto(produtoFake.id, 'Arroz Integral', mercearia);

      controller
        ..salvo(novo)
        ..salvo(editado);

      expect(controller.produtos, [editado, novo]);
    });

    test(
      'Cenário: Dado um produto, quando excluo, então ele sai da lista',
      () async {
        final repository = ProdutoRepositoryFake(produtos: [produtoFake]);
        final controller = produtosControllerDeTeste(repository: repository);
        await controller.carregar(produtoFake.filialId);

        final resultado = await controller.excluir(produtoFake);

        expect(resultado.isSuccess, isTrue);
        expect(controller.produtos, isEmpty);
        expect(repository.excluidos, [produtoFake.id]);
      },
    );
  });
}
