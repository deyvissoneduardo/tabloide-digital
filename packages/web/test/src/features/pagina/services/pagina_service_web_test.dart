import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

final class _IdentidadeLenta implements IdentidadeRepository {
  final pedido = Completer<void>();

  final resposta = Completer<Either<Falha, IdentidadeResponse>>();

  @override
  Future<Either<Falha, IdentidadeResponse>> obter() {
    pedido.complete();
    return resposta.future;
  }

  @override
  Future<Either<Falha, IdentidadeResponse>> editar(IdentidadeRequest r) =>
      throw UnimplementedError();

  @override
  Future<Either<Falha, IdentidadeResponse>> enviarLogo({
    required List<int> bytes,
    required String nomeArquivo,
  }) => throw UnimplementedError();
}

void main() {
  group('Funcionalidade: service da seção Página na web', () {
    test('Cenário: Dado os 3 repositories, quando carrego, então as chamadas saem em paralelo', () async {
      final estrutura = EstruturaRepositoryFake();
      final identidade = _IdentidadeLenta();
      final panfletos = PanfletoRepositoryFake(panfletos: [panfletoFake]);
      final service = PaginaServiceWeb(estrutura, identidade, panfletos);

      final carregando = service.carregar('f1');
      await identidade.pedido.future;
      await Future<void>.delayed(Duration.zero);

      expect(estrutura.obtidas, ['f1'], reason: 'não esperou a identidade');
      identidade.resposta.complete(const Success(identidadeFake));
      expect((await carregando).isSuccess, isTrue);
    });

    test(
      'Cenário: Dado falha nos panfletos, quando carrego, então recebo a falha',
      () async {
        final service = PaginaServiceWeb(
          EstruturaRepositoryFake(),
          IdentidadeRepositoryFake(),
          PanfletoRepositoryFake(falhaSimulada: const FalhaSemConexao()),
        );

        expect(
          await service.carregar('f1'),
          const Failure<Falha, DadosPagina>(FalhaSemConexao()),
        );
      },
    );

    test('Cenário: Dado falha na estrutura e na identidade, quando carrego, então a primeira falha vence', () async {
      final service = PaginaServiceWeb(
        EstruturaRepositoryFake(falha: const FalhaSemConexao()),
        IdentidadeRepositoryFake(falhaSimulada: const FalhaInesperada('x')),
        PanfletoRepositoryFake(),
      );

      expect(
        await service.carregar('f1'),
        const Failure<Falha, DadosPagina>(FalhaSemConexao()),
      );
    });

    test('Cenário: Dado um agendado e um vigente, quando carrego, então o vigente é escolhido pela situação', () async {
      final service = PaginaServiceWeb(
        EstruturaRepositoryFake(),
        IdentidadeRepositoryFake(),
        PanfletoRepositoryFake(panfletos: [panfletoFakeAgendado, panfletoFake]),
      );

      final dados = (await service.carregar('f1')).fold((_) => null, (d) => d)!;

      expect(dados.panfletoVigente, panfletoFake);
      expect(dados.estrutura, estruturaFake);
    });

    test('Cenário: Dado só um agendado, quando carrego, então não há panfleto vigente', () async {
      final service = PaginaServiceWeb(
        EstruturaRepositoryFake(),
        IdentidadeRepositoryFake(),
        PanfletoRepositoryFake(panfletos: [panfletoFakeAgendado]),
      );

      final dados = (await service.carregar('f1')).fold((_) => null, (d) => d)!;

      expect(dados.panfletoVigente, isNull);
    });

    test('Cenário: Dado uma nova ordem, quando publico, então repasso ao repository', () async {
      final estrutura = EstruturaRepositoryFake();
      final service = PaginaServiceWeb(
        estrutura,
        IdentidadeRepositoryFake(),
        PanfletoRepositoryFake(),
      );
      const pedido = EstruturaRequest([]);

      await service.publicar('f1', pedido);

      expect(estrutura.pedidos, [pedido]);
    });
  });
}
