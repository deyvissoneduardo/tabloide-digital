import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

class _PanfletoRepositoryMock extends Mock implements PanfletoRepository {}

const _filial = 'filial';

const _pedido = PanfletoRequest();

void main() {
  group('Funcionalidade: service de panfletos na web', () {
    late _PanfletoRepositoryMock repository;
    late PanfletoServiceWeb service;
    setUp(() {
      repository = _PanfletoRepositoryMock();
      service = PanfletoServiceWeb(repository);
    });

    test('Cenário: Dado o repository respondendo, quando listo, crio, edito, troco a imagem e excluo, então devolvo o mesmo resultado de cada chamada', () async {
      when(() => repository.listar(_filial))
          .thenAnswer((_) async => Success([panfletoFake]));
      when(
        () => repository.criar(
          _filial,
          _pedido,
          bytes: [1],
          nomeArquivo: 'p.jpg',
        ),
      ).thenAnswer((_) async => Success(panfletoFake));
      when(() => repository.editar(_filial, 'id', _pedido))
          .thenAnswer((_) async => Success(panfletoFake));
      when(
        () => repository.trocarImagem(
          _filial,
          'id',
          bytes: [2],
          nomeArquivo: 'n.jpg',
        ),
      ).thenAnswer((_) async => Success(panfletoFake));
      when(() => repository.excluir(_filial, 'id'))
          .thenAnswer((_) async => const Failure(FalhaSemConexao()));

      expect((await service.listar(_filial)).fold((_) => null, (l) => l), [
        panfletoFake,
      ]);
      expect(
        await service.criar(_filial, _pedido, bytes: [1], nomeArquivo: 'p.jpg'),
        Success<Falha, PanfletoResponse>(panfletoFake),
      );
      expect(
        await service.editar(_filial, 'id', _pedido),
        Success<Falha, PanfletoResponse>(panfletoFake),
      );
      expect(
        await service.trocarImagem(
          _filial,
          'id',
          bytes: [2],
          nomeArquivo: 'n.jpg',
        ),
        Success<Falha, PanfletoResponse>(panfletoFake),
      );
      expect(
        await service.excluir(_filial, 'id'),
        const Failure<Falha, Nada>(FalhaSemConexao()),
      );
    });
  });
}
