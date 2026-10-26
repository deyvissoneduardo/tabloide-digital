import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

void main() {
  group('Funcionalidade: service de produtos na web', () {
    test('Cenário: Dado o repository, quando chamo cada ação, então repasso para ele', () async {
      final repository = ProdutoRepositoryFake(produtos: [produtoFake]);
      final service = ProdutoServiceWeb(repository);
      const pedido = ProdutoRequest(
        nome: 'Feijão',
        categoriaId: 'c1',
        precoPromocionalCentavos: 899,
      );

      final lista = await service.listar('f1');
      await service.criar(
        'f1',
        pedido,
        foto: (bytes: Uint8List.fromList([1]), nome: 'feijao.jpg'),
      );
      await service.editar(
        'f1',
        produtoFake.id,
        EditarProdutoRequest.entre(produtoFake, pedido),
      );
      await service.trocarFoto('f1', produtoFake.id, (
        bytes: [2],
        nome: 'nova.jpg',
      ));
      await service.removerFoto('f1', produtoFake.id);
      await service.excluir('f1', produtoFake.id);

      expect(lista.fold((_) => null, (l) => l), [produtoFake]);
      expect(repository.pedidos, [pedido]);
      expect(repository.edicoes, hasLength(1));
      expect(repository.fotosEnviadas, ['feijao.jpg', 'nova.jpg']);
      expect(repository.fotosRemovidas, [produtoFake.id]);
      expect(repository.excluidos, [produtoFake.id]);
    });
  });
}
