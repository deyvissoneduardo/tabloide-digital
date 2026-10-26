import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

void main() {
  group('Funcionalidade: service de categorias no app', () {
    test('Cenário: Dado o repository, quando listo, crio, renomeio e excluo, então repasso cada chamada', () async {
      final repository = CategoriaRepositoryFake(
        categorias: [categoriaFakeVazia],
      );
      final service = CategoriaServiceApp(repository);

      final lista = await service.listar('f1');
      final criada = await service.criar(
        'f1',
        const CategoriaRequest(nome: 'Padaria'),
      );
      final id = criada.fold((_) => '', (c) => c.id);
      await service.renomear('f1', id, const CategoriaRequest(nome: 'Pães'));
      await service.excluir('f1', categoriaFakeVazia.id);

      expect(lista.fold((_) => null, (l) => l), [categoriaFakeVazia]);
      expect(repository.pedidos, const [
        CategoriaRequest(nome: 'Padaria'),
        CategoriaRequest(nome: 'Pães'),
      ]);
      expect(repository.excluidos, [categoriaFakeVazia.id]);
      expect(repository.categorias.single.nome, 'Pães');
    });
  });
}
