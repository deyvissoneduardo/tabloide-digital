import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

void main() {
  group('Funcionalidade: lista de categorias na web', () {
    test('Cenário: Dado categorias fora de ordem, quando carrego, então ficam em ordem alfabética (RN30)', () async {
      final controller = categoriasControllerDeTeste(
        repository: CategoriaRepositoryFake(
          categorias: [categoriaFake, categoriaFakeVazia],
        ),
      );

      await controller.carregar('f1');

      expect(controller.filialId, 'f1');
      expect(controller.categorias, [categoriaFakeVazia, categoriaFake]);
    });

    test('Cenário: Dado falha na API, quando carrego, então o estado guarda a falha', () async {
      final controller = categoriasControllerDeTeste(
        repository: CategoriaRepositoryFake(
          falhaSimulada: const FalhaSemConexao(),
        ),
      );

      await controller.carregar('f1');

      expect(
        controller.estado,
        isA<CategoriasComFalha>().having(
          (e) => e.falha,
          'falha',
          const FalhaSemConexao(),
        ),
      );
    });

    test('Cenário: Dado uma categoria renomeada, quando salva, então substituo e reordeno', () async {
      final controller = categoriasControllerDeTeste(
        repository: CategoriaRepositoryFake(
          categorias: [categoriaFake, categoriaFakeVazia],
        ),
      );
      await controller.carregar('f1');
      final renomeada = CategoriaResponse(
        id: categoriaFake.id,
        nome: 'Açougue',
        produtos: categoriaFake.produtos,
        podeExcluir: false,
        criadoEm: categoriaFake.criadoEm,
        atualizadoEm: categoriaFake.atualizadoEm,
      );

      controller.salva(renomeada);

      expect(controller.categorias, [renomeada, categoriaFakeVazia]);
    });

    test('Cenário: Dado uma categoria com produtos ativos, quando excluo, então recebo a falha e ela continua na lista (RN20)', () async {
      final controller = categoriasControllerDeTeste(
        repository: CategoriaRepositoryFake(
          categorias: [categoriaFake, categoriaFakeVazia],
        ),
      );
      await controller.carregar('f1');

      final bloqueada = await controller.excluir(categoriaFake);
      final liberada = await controller.excluir(categoriaFakeVazia);

      expect(bloqueada.isFailure, isTrue);
      expect(liberada.isSuccess, isTrue);
      expect(controller.categorias, [categoriaFake]);
    });
  });
}
