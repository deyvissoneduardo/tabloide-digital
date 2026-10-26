import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

void main() {
  group('Funcionalidade: produtos de mentira para testes', () {
    test('Cenário: Dado um pedido com data de início futura e foto, quando cadastro, então o produto fica agendado e com foto', () async {
      final repository = ProdutoRepositoryFake();
      final amanha = DataDia.hoje().add(const Duration(days: 1));

      final resultado = await repository.criar(
        'f1',
        ProdutoRequest(
          nome: 'Feijão',
          categoriaId: 'c1',
          precoPromocionalCentavos: 899,
          dataInicio: amanha,
        ),
        foto: (bytes: [1], nome: 'feijao.jpg'),
      );

      final produto = resultado.fold((_) => null, (p) => p)!;
      expect(produto.vigencia.situacao, SituacaoVigencia.agendado);
      expect(produto.urlFoto, 'https://midia.fake/produto/feijao.jpg');
      expect(repository.fotosEnviadas, ['feijao.jpg']);
    });

    test('Cenário: Dado uma edição que limpa a observação e a data limite, quando edito, então os campos ficam nulos', () async {
      final repository = ProdutoRepositoryFake(produtos: [produtoFake]);
      final pedido = EditarProdutoRequest.entre(
        produtoFake,
        ProdutoRequest(
          nome: produtoFake.nome,
          categoriaId: produtoFake.categoria.id,
          precoPromocionalCentavos: 1999,
          precoOriginalCentavos: 2649,
          quantidade: '5kg',
          dataInicio: produtoFake.vigencia.dataInicio,
        ),
      );

      final produto = (await repository.editar(
        'f1',
        produtoFake.id,
        pedido,
      )).fold((_) => null, (p) => p)!;

      expect(produto.precoPromocionalCentavos, 1999);
      expect(produto.observacao, isNull);
      expect(produto.vigencia.dataLimite, isNull);
      expect(produto.urlFoto, produtoFake.urlFoto);
    });

    test('Cenário: Dado um produto com foto, quando removo a foto e excluo, então registro as duas ações', () async {
      final repository = ProdutoRepositoryFake(produtos: [produtoFake]);

      final semFoto = await repository.removerFoto('f1', produtoFake.id);
      await repository.excluir('f1', produtoFake.id);

      expect(semFoto.fold((_) => 'falhou', (p) => p.urlFoto), isNull);
      expect(repository.fotosRemovidas, [produtoFake.id]);
      expect(repository.produtos, isEmpty);
    });
  });
}
