import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/nada.dart';
import 'package:tabloide_core/src/features/panfletos/repositories/panfleto_repository.dart';
import 'package:tabloide_core/src/features/vigencia/models/data_dia.dart';
import 'package:tabloide_core/src/features/vigencia/models/situacao_vigencia.dart';
import 'package:tabloide_core/src/features/vigencia/models/vigencia.dart';
import 'package:tabloide_core/src/requests/panfleto_request.dart';
import 'package:tabloide_core/src/responses/panfleto_response.dart';

final panfletoFake = PanfletoResponse(
  id: '0192f0c0-8e40-7d32-9f5c-3e4f5a6b7c03',
  filialId: '0192f0b4-7d3f-7c21-8e4b-2d3e4f5a6b02',
  urlImagem:
      'https://xyz.supabase.co/storage/v1/object/public/midia/'
      '0192f0a1-6c2e-7b10-9f3a-1c2d3e4f5a01/panfleto/0192f0c0.webp',
  largura: 1600,
  altura: 2263,
  vigencia: Vigencia(
    dataInicio: DateTime(2026, 10, 18),
    dataLimite: DateTime(2026, 10, 31),
    situacao: SituacaoVigencia.vigente,
    editavel: true,
  ),
  criadoEm: DateTime.utc(2026, 10, 18, 13, 10),
);

final panfletoFakeAgendado = PanfletoResponse(
  id: '0192f0c0-8e40-7d32-9f5c-3e4f5a6b7c04',
  filialId: '0192f0b4-7d3f-7c21-8e4b-2d3e4f5a6b02',
  urlImagem:
      'https://xyz.supabase.co/storage/v1/object/public/midia/'
      '0192f0a1-6c2e-7b10-9f3a-1c2d3e4f5a01/panfleto/0192f0c1.webp',
  largura: 1600,
  altura: 2263,
  vigencia: Vigencia(
    dataInicio: DateTime(2026, 11, 1),
    situacao: SituacaoVigencia.agendado,
    editavel: true,
  ),
  criadoEm: DateTime.utc(2026, 10, 19, 9),
);

final class PanfletoRepositoryFake implements PanfletoRepository {
  PanfletoRepositoryFake({
    List<PanfletoResponse>? panfletos,
    this.falhaSimulada,
    this.atraso = Duration.zero,
  }) : panfletos = [...?panfletos];

  final List<PanfletoResponse> panfletos;

  Falha? falhaSimulada;

  final Duration atraso;

  final pedidos = <PanfletoRequest>[];

  final imagensEnviadas = <String>[];

  final excluidos = <String>[];

  @override
  Future<Either<Falha, List<PanfletoResponse>>> listar(String filialId) =>
      _responder(() => [...panfletos]);

  @override
  Future<Either<Falha, PanfletoResponse>> obter(
    String filialId,
    String id,
  ) async {
    await Future<void>.delayed(atraso);
    if (falhaSimulada case final falha?) return Failure(falha);
    return switch (panfletos.where((p) => p.id == id).firstOrNull) {
      final panfleto? => Success(panfleto),
      null => const Failure(_naoEncontrado),
    };
  }

  @override
  Future<Either<Falha, PanfletoResponse>> criar(
    String filialId,
    PanfletoRequest request, {
    required List<int> bytes,
    required String nomeArquivo,
  }) {
    pedidos.add(request);
    imagensEnviadas.add(nomeArquivo);
    return _responder(() {
      final hoje = DataDia.hoje();
      final inicio = request.dataInicio ?? hoje;
      final panfleto = PanfletoResponse(
        id: 'panfleto-fake-${panfletos.length + 1}',
        filialId: filialId,
        urlImagem: 'https://midia.fake/panfleto/$nomeArquivo',
        largura: 1600,
        altura: 2263,
        vigencia: Vigencia(
          dataInicio: inicio,
          dataLimite: request.dataLimite,
          situacao: inicio.isAfter(hoje)
              ? SituacaoVigencia.agendado
              : SituacaoVigencia.vigente,
          editavel: true,
        ),
        criadoEm: DateTime.now().toUtc(),
      );
      panfletos.add(panfleto);
      return panfleto;
    });
  }

  @override
  Future<Either<Falha, PanfletoResponse>> editar(
    String filialId,
    String id,
    PanfletoRequest request,
  ) {
    pedidos.add(request);
    return _responder(
      () => _substituir(id, (atual) {
        final vigencia = atual.vigencia;
        return _copiar(
          atual,
          vigencia: Vigencia(
            dataInicio: request.dataInicio ?? vigencia.dataInicio,
            dataLimite: request.dataLimite ?? vigencia.dataLimite,
            situacao: vigencia.situacao,
            editavel: vigencia.editavel,
          ),
        );
      }),
    );
  }

  @override
  Future<Either<Falha, PanfletoResponse>> trocarImagem(
    String filialId,
    String id, {
    required List<int> bytes,
    required String nomeArquivo,
  }) {
    imagensEnviadas.add(nomeArquivo);
    return _responder(
      () => _substituir(
        id,
        (atual) => _copiar(
          atual,
          urlImagem: 'https://midia.fake/panfleto/$nomeArquivo',
        ),
      ),
    );
  }

  @override
  Future<Either<Falha, Nada>> excluir(String filialId, String id) {
    excluidos.add(id);
    return _responder(() {
      panfletos.removeWhere((p) => p.id == id);
      return const Nada();
    });
  }

  PanfletoResponse _substituir(
    String id,
    PanfletoResponse Function(PanfletoResponse atual) alterar,
  ) {
    final i = panfletos.indexWhere((p) => p.id == id);
    return panfletos[i] = alterar(panfletos[i]);
  }

  PanfletoResponse _copiar(
    PanfletoResponse atual, {
    String? urlImagem,
    Vigencia? vigencia,
  }) => PanfletoResponse(
    id: atual.id,
    filialId: atual.filialId,
    urlImagem: urlImagem ?? atual.urlImagem,
    largura: atual.largura,
    altura: atual.altura,
    vigencia: vigencia ?? atual.vigencia,
    criadoEm: atual.criadoEm,
    excluidoEm: atual.excluidoEm,
  );

  Future<Either<Falha, T>> _responder<T>(T Function() acao) async {
    await Future<void>.delayed(atraso);
    return switch (falhaSimulada) {
      final falha? => Failure(falha),
      null => Success(acao()),
    };
  }
}

const _naoEncontrado = FalhaApi(
  codigo: 'RECURSO_NAO_ENCONTRADO',
  mensagem: 'Não encontrado.',
);
