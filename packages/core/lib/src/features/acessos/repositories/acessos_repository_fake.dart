import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/features/acessos/models/periodo_acessos.dart';
import 'package:tabloide_core/src/features/acessos/repositories/acessos_repository.dart';
import 'package:tabloide_core/src/features/filiais/repositories/filial_repository_fake.dart';
import 'package:tabloide_core/src/responses/acessos_panfletos_response.dart';
import 'package:tabloide_core/src/responses/resumo_acessos_response.dart';

typedef PedidoAcessos = ({
  PeriodoAcessos periodo,
  String? filialId,
  bool panfletos,
});

final class AcessosRepositoryFake implements AcessosRepository {
  AcessosRepositoryFake({
    ResumoAcessosResponse? resumo,
    AcessosPanfletosResponse? panfletos,
    this.falhaSimulada,
    this.atraso = Duration.zero,
  }) : _resumo = resumo ?? resumoAcessosFake,
       _panfletos = panfletos ?? panfletosAcessosFake;

  final ResumoAcessosResponse _resumo;

  final AcessosPanfletosResponse _panfletos;

  Falha? falhaSimulada;

  final Duration atraso;

  final pedidos = <PedidoAcessos>[];

  @override
  Future<Either<Falha, ResumoAcessosResponse>> resumo(
    PeriodoAcessos periodo, {
    String? filialId,
  }) async {
    pedidos.add((periodo: periodo, filialId: filialId, panfletos: false));
    await Future<void>.delayed(atraso);
    return switch (falhaSimulada) {
      final falha? => Failure(falha),
      null => Success(_resumo),
    };
  }

  @override
  Future<Either<Falha, AcessosPanfletosResponse>> panfletos(
    String filialId,
    PeriodoAcessos periodo,
  ) async {
    pedidos.add((periodo: periodo, filialId: filialId, panfletos: true));
    await Future<void>.delayed(atraso);
    return switch (falhaSimulada) {
      final falha? => Failure(falha),
      null => Success(_panfletos),
    };
  }
}

const _porHora = [
  0, 0, 0, 0, 0, 0, 2, 15, 60, 120, 160, 150, //
  140, 130, 120, 110, 130, 170, 190, 140, 70, 20, 5, 1,
];

const _porDiaSemana = [210, 190, 200, 230, 310, 400, 300];

const _diasFake = [
  41, 38, 52, 47, 60, 85, 72, 40, 35, 50, //
  48, 66, 90, 74, 39, 44, 70, 81, 95, 120, //
  88, 52, 47, 58, 63, 91, 110, 76, 49, 44,
];

final resumoAcessosFake = ResumoAcessosResponse(
  inicio: DateTime(2026, 10, 11),
  fim: DateTime(2026, 11, 9),
  total: 1925,
  porFilial: [
    AcessosFilialResponse(
      filialId: filialFake.id,
      nome: filialFake.nome,
      excluida: false,
      total: 1265,
    ),
    AcessosFilialResponse(
      filialId: filialFakeBairro.id,
      nome: filialFakeBairro.nome,
      excluida: false,
      total: 610,
    ),
    const AcessosFilialResponse(
      filialId: '0192f0b4-7d3f-7c21-8e4b-2d3e4f5a6b09',
      nome: 'Loja antiga',
      excluida: true,
      total: 50,
    ),
  ],
  porDia: [
    for (final (i, total) in _diasFake.indexed)
      AcessosDiaResponse(data: DateTime(2026, 10, 11 + i), total: total),
  ],
  iniciosPanfleto: [
    InicioPanfletoResponse(
      data: DateTime(2026, 10, 20),
      filialId: filialFake.id,
    ),
  ],
  pico: const PicoAcessosResponse(
    disponivel: true,
    minimo: 100,
    porHora: _porHora,
    porDiaSemana: _porDiaSemana,
  ),
);

final resumoAcessosPoucosFake = ResumoAcessosResponse(
  inicio: DateTime(2026, 11, 3),
  fim: DateTime(2026, 11, 9),
  total: 40,
  porFilial: [
    AcessosFilialResponse(
      filialId: filialFake.id,
      nome: filialFake.nome,
      excluida: false,
      total: 40,
    ),
  ],
  porDia: [
    for (final (i, total) in [3, 5, 0, 8, 6, 12, 6].indexed)
      AcessosDiaResponse(data: DateTime(2026, 11, 3 + i), total: total),
  ],
  iniciosPanfleto: const [],
  pico: const PicoAcessosResponse(disponivel: false, minimo: 100),
);

final resumoAcessosVazioFake = ResumoAcessosResponse(
  inicio: DateTime(2026, 11, 3),
  fim: DateTime(2026, 11, 9),
  total: 0,
  porFilial: [
    AcessosFilialResponse(
      filialId: filialFake.id,
      nome: filialFake.nome,
      excluida: false,
      total: 0,
    ),
  ],
  porDia: [
    for (var i = 0; i < 7; i++)
      AcessosDiaResponse(data: DateTime(2026, 11, 3 + i), total: 0),
  ],
  iniciosPanfleto: const [],
  pico: const PicoAcessosResponse(disponivel: false, minimo: 100),
);

final panfletosAcessosFake = AcessosPanfletosResponse([
  AcessosPanfletoResponse(
    panfletoId: '0193a1b2-0000-7000-8000-000000000001',
    dataInicio: DateTime(2026, 10, 20),
    dataLimite: DateTime(2026, 11, 15),
    dataFimContagem: DateTime(2026, 11, 9),
    situacao: SituacaoAcessoPanfleto.vigente,
    totalAcessos: 980,
    dias: 21,
    mediaPorDia: 46.7,
  ),
  AcessosPanfletoResponse(
    panfletoId: '0193a1b2-0000-7000-8000-000000000002',
    dataInicio: DateTime(2026, 10, 1),
    dataLimite: DateTime(2026, 10, 19),
    dataFimContagem: DateTime(2026, 10, 19),
    situacao: SituacaoAcessoPanfleto.vencido,
    totalAcessos: 610,
    dias: 19,
    mediaPorDia: 32.1,
  ),
]);
