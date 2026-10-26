import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

void main() {
  group('Funcionalidade: formulário de categoria na web', () {
    test('Cenário: Dado um nome novo, quando salvo, então crio e concluo com a categoria', () async {
      final repository = CategoriaRepositoryFake();
      final controller = categoriaFormControllerDeTeste(repository: repository);

      await controller.salvar(filialId: 'f1', nome: 'Hortifrúti');

      expect(
        controller.estado,
        isA<CategoriaFormConcluido>().having(
          (e) => e.categoria.nome,
          'nome',
          'Hortifrúti',
        ),
      );
      expect(repository.pedidos, const [CategoriaRequest(nome: 'Hortifrúti')]);
    });

    test('Cenário: Dado uma categoria existente, quando salvo, então renomeio em vez de criar', () async {
      final repository = CategoriaRepositoryFake(categorias: [categoriaFake]);
      final controller = categoriaFormControllerDeTeste(repository: repository);

      await controller.salvar(
        filialId: 'f1',
        nome: 'Mercearia e Grãos',
        categoria: categoriaFake,
      );

      expect(repository.categorias.single.nome, 'Mercearia e Grãos');
      expect(repository.categorias.single.id, categoriaFake.id);
    });

    test('Cenário: Dado um nome repetido, quando salvo, então o erro vai para o campo Nome (RN43) e some ao editar', () async {
      final controller = categoriaFormControllerDeTeste(
        repository: CategoriaRepositoryFake(categorias: [categoriaFake]),
      );

      await controller.salvar(filialId: 'f1', nome: 'mercearia');

      expect(
        controller.erroNome,
        'Já existe uma categoria com esse nome nesta filial.',
      );
      expect(controller.estado, isA<CategoriaFormComFalha>());

      controller.limparErroNome();

      expect(controller.erroNome, isNull);
    });

    test('Cenário: Dado falha sem campo, quando salvo, então o campo fica sem erro e o estado guarda a falha', () async {
      final controller = categoriaFormControllerDeTeste(
        repository: CategoriaRepositoryFake(
          falhaSimulada: const FalhaSemConexao(),
        ),
      );

      await controller.salvar(filialId: 'f1', nome: 'Padaria');

      expect(controller.erroNome, isNull);
      expect(controller.estado, isA<CategoriaFormComFalha>());
    });
  });
}
