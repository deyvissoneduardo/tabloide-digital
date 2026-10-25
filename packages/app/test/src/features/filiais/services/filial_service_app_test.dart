import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

class _FilialRepositoryMock extends Mock implements FilialRepository {}

final _pedido = FilialRequest(
  nome: 'Centro',
  endereco: filialFake.endereco,
  fusoHorario: 'America/Sao_Paulo',
);

void main() {
  group('Funcionalidade: service de filiais no app', () {
    late _FilialRepositoryMock repository;
    late FilialServiceApp service;
    setUp(() {
      repository = _FilialRepositoryMock();
      service = FilialServiceApp(repository, CepRepositoryFake());
    });

    test('Cenário: Dado o repository respondendo, quando listo, crio, edito e excluo, então devolvo o mesmo resultado de cada chamada', () async {
      when(repository.listar).thenAnswer((_) async => Success([filialFake]));
      when(() => repository.criar(_pedido))
          .thenAnswer((_) async => Success(filialFake));
      when(() => repository.editar('id', _pedido))
          .thenAnswer((_) async => Success(filialFake));
      when(() => repository.excluir('id'))
          .thenAnswer((_) async => const Failure(FalhaSemConexao()));

      expect((await service.listar()).fold((_) => null, (l) => l), [
        filialFake,
      ]);
      expect(
        await service.criar(_pedido),
        Success<Falha, FilialResponse>(filialFake),
      );
      expect(
        await service.editar('id', _pedido),
        Success<Falha, FilialResponse>(filialFake),
      );
      expect(
        await service.excluir('id'),
        const Failure<Falha, Nada>(FalhaSemConexao()),
      );
      verify(() => repository.excluir('id')).called(1);
    });

    test('Cenário: Dado um CEP, quando busco, então repasso a busca ao repository de CEP', () async {
      final cep = CepRepositoryFake();

      final resultado = await FilialServiceApp(
        repository,
        cep,
      ).buscarCep('01001000');

      expect(resultado, const Success<Falha, CepResponse>(cepFake));
      expect(cep.buscados, ['01001000']);
    });
  });
}
