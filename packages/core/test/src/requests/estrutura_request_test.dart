import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

void main() {
  group('Funcionalidade: Estrutura da filial', () {
    test('Cenário: Dado a ordem em edição, quando monto com EstruturaRequest.daEstrutura, então mantém a ordem das categorias e dos produtos', () {
      final [hortifruti, mercearia] = estruturaFake.categorias;
      final emEdicao = [
        mercearia,
        hortifruti.comProdutos(hortifruti.produtos.reversed.toList()),
      ];

      final pedido = EstruturaRequest.daEstrutura(emEdicao);

      expect(pedido.categorias, [
        CategoriaOrdenada(
          id: mercearia.id,
          produtos: [produtoEstruturaFakeArroz.id],
        ),
        CategoriaOrdenada(
          id: hortifruti.id,
          produtos: [
            produtoEstruturaFakeMaca.id,
            produtoEstruturaFakeBanana.id,
          ],
        ),
      ]);
    });

    test('Cenário: Dado um pedido, quando gero o JSON, então é { categorias: [{ id, produtos: [ids] }] }', () {
      const pedido = EstruturaRequest([
        CategoriaOrdenada(id: 'c1', produtos: ['p1', 'p2']),
        CategoriaOrdenada(id: 'c2', produtos: []),
      ]);

      expect(pedido.toJson(), {
        'categorias': [
          {
            'id': 'c1',
            'produtos': ['p1', 'p2'],
          },
          {'id': 'c2', 'produtos': <String>[]},
        ],
      });
    });
  });
}
