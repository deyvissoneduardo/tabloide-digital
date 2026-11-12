import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

final class _RepositoryControlado implements AcessosRepository {
  final resumos = <Completer<Either<Falha, ResumoAcessosResponse>>>[];

  @override
  Future<Either<Falha, ResumoAcessosResponse>> resumo(
    PeriodoAcessos periodo, {
    String? filialId,
  }) {
    final completer = Completer<Either<Falha, ResumoAcessosResponse>>();
    resumos.add(completer);
    return completer.future;
  }

  @override
  Future<Either<Falha, AcessosPanfletosResponse>> panfletos(
    String filialId,
    PeriodoAcessos periodo,
  ) async => Success(panfletosAcessosFake);
}

void main() {
  group('Funcionalidade: controller de acessos do app', () {
    late AcessosRepositoryFake repository;
    late AcessosController controller;

    setUp(() {
      repository = AcessosRepositoryFake();
      controller = acessosControllerDeTeste(repository: repository);
    });

    test('Cenário: Dado 2 filiais, quando as filiais chegam, então carrego o resumo de 30 dias de todas e deixo os panfletos ociosos', () async {
      await controller.filiaisMudaram(['f1', 'f2']);

      expect(repository.pedidos, [
        (
          periodo: const PeriodoPredefinido(30),
          filialId: null,
          panfletos: false,
        ),
      ]);
      expect(controller.resumo, isA<ResumoAcessosCarregado>());
      expect(controller.panfletos, isA<PanfletosAcessosOcioso>());
    });

    test('Cenário: Dado 1 filial só, quando as filiais chegam, então carrego também os panfletos dela', () async {
      await controller.filiaisMudaram(['f1']);

      expect(repository.pedidos, [
        (
          periodo: const PeriodoPredefinido(30),
          filialId: null,
          panfletos: false,
        ),
        (
          periodo: const PeriodoPredefinido(30),
          filialId: 'f1',
          panfletos: true,
        ),
      ]);
      expect(
        controller.panfletos,
        isA<PanfletosAcessosCarregados>().having(
          (e) => e.itens,
          'itens',
          panfletosAcessosFake.itens,
        ),
      );
    });

    test('Cenário: Dado o resumo carregado, quando mudo para 7 dias, então refaço a chamada com o período novo', () async {
      await controller.filiaisMudaram(['f1', 'f2']);

      await controller.mudarPeriodo(const PeriodoPredefinido(7));
      await controller.mudarPeriodo(const PeriodoPredefinido(7));

      expect(repository.pedidos.last.periodo, const PeriodoPredefinido(7));
      expect(repository.pedidos, hasLength(2));
      expect(
        controller.resumo,
        isA<ResumoAcessosCarregado>().having(
          (e) => e.periodo,
          'periodo',
          const PeriodoPredefinido(7),
        ),
      );
    });

    test('Cenário: Dado 2 filiais, quando escolho uma, então o resumo é filtrado e os panfletos dela carregam; voltando a "todas", ficam ociosos', () async {
      await controller.filiaisMudaram(['f1', 'f2']);

      await controller.mudarFilial('f2');

      expect(repository.pedidos.skip(1), [
        (periodo: PeriodoAcessos.padrao, filialId: 'f2', panfletos: false),
        (periodo: PeriodoAcessos.padrao, filialId: 'f2', panfletos: true),
      ]);
      expect(controller.panfletos, isA<PanfletosAcessosCarregados>());

      await controller.mudarFilial(null);

      expect(controller.panfletos, isA<PanfletosAcessosOcioso>());
    });

    test('Cenário: Dado a filial escolhida excluída, quando as filiais mudam, então volto para "todas" e recarrego', () async {
      await controller.filiaisMudaram(['f1', 'f2']);
      await controller.mudarFilial('f2');

      await controller.filiaisMudaram(['f1', 'f3']);

      expect(controller.filialId, isNull);
      expect(repository.pedidos.last, (
        periodo: PeriodoAcessos.padrao,
        filialId: null,
        panfletos: false,
      ));
    });

    test('Cenário: Dado sem conexão, quando carrego, então o resumo fica com falha', () async {
      repository.falhaSimulada = const FalhaSemConexao();

      await controller.filiaisMudaram(['f1', 'f2']);

      expect(
        controller.resumo,
        isA<ResumoAcessosComFalha>().having(
          (e) => e.falha,
          'falha',
          const FalhaSemConexao(),
        ),
      );
    });

    test('Cenário: Dado duas trocas rápidas de período, quando a resposta antiga chega por último, então ela é descartada', () async {
      final controlado = _RepositoryControlado();
      final controller = AcessosController(AcessosServiceApp(controlado));
      final primeira = controller.filiaisMudaram(['f1', 'f2']);
      final segunda = controller.mudarPeriodo(const PeriodoPredefinido(7));

      controlado.resumos[1].complete(Success(resumoAcessosPoucosFake));
      await segunda;
      controlado.resumos[0].complete(Success(resumoAcessosFake));
      await primeira;

      expect(
        controller.resumo,
        isA<ResumoAcessosCarregado>().having(
          (e) => e.resumo,
          'resumo',
          resumoAcessosPoucosFake,
        ),
      );
    });

    test('Cenário: Dado o resumo carregado, quando recarrego pelo filtro, então mantenho o resultado anterior e marco "recarregando"', () async {
      final controlado = _RepositoryControlado();
      final controller = AcessosController(AcessosServiceApp(controlado));
      final primeira = controller.filiaisMudaram(['f1', 'f2']);
      controlado.resumos[0].complete(Success(resumoAcessosFake));
      await primeira;

      final segunda = controller.mudarPeriodo(const PeriodoPredefinido(15));

      expect(controller.recarregando, isTrue);
      expect(controller.resumo, isA<ResumoAcessosCarregado>());
      controlado.resumos[1].complete(Success(resumoAcessosPoucosFake));
      await segunda;
      expect(controller.recarregando, isFalse);
    });
  });
}
