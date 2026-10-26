import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

void main() {
  group('Funcionalidade: categorias de mentira para testes', () {
    test('Cenário: Dado uma categoria com o mesmo nome em outra caixa, quando crio, então recebo CATEGORIA_JA_EXISTE', () async {
      final repository = CategoriaRepositoryFake(categorias: [categoriaFake]);

      final resultado = await repository.criar(
        'f1',
        const CategoriaRequest(nome: ' MERCEARIA '),
      );

      expect(
        (resultado as Failure<Falha, CategoriaResponse>).falha,
        isA<FalhaApi>().having(
          (f) => f.codigo,
          'codigo',
          'CATEGORIA_JA_EXISTE',
        ),
      );
    });

    test('Cenário: Dado um nome novo, quando crio e renomeio, então a lista guarda o nome final sem produtos', () async {
      final repository = CategoriaRepositoryFake();

      final criada = await repository.criar(
        'f1',
        const CategoriaRequest(nome: 'Hortifrúti'),
      );
      final id = criada.fold((_) => '', (c) => c.id);
      await repository.renomear(
        'f1',
        id,
        const CategoriaRequest(nome: 'Frutas'),
      );

      expect(repository.categorias.single.nome, 'Frutas');
      expect(repository.categorias.single.podeExcluir, isTrue);
    });

    test('Cenário: Dado uma categoria com produtos ativos, quando excluo, então recebo CATEGORIA_COM_PRODUTOS_ATIVOS e ela fica', () async {
      final repository = CategoriaRepositoryFake(
        categorias: [categoriaFake, categoriaFakeVazia],
      );

      final bloqueada = await repository.excluir('f1', categoriaFake.id);
      final liberada = await repository.excluir('f1', categoriaFakeVazia.id);

      expect(bloqueada.isFailure, isTrue);
      expect(liberada.isSuccess, isTrue);
      expect(repository.categorias, [categoriaFake]);
    });
  });
}
