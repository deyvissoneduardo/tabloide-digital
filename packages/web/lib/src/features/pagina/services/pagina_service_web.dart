import 'package:tabloide_core/tabloide_core.dart';

final class PaginaServiceWeb {
  const PaginaServiceWeb(this._estrutura, this._identidade, this._panfletos);

  final EstruturaRepository _estrutura;

  final IdentidadeRepository _identidade;

  final PanfletoRepository _panfletos;

  /// Estrutura, identidade e panfletos em paralelo; o vigente é o panfleto com
  /// situação VIGENTE. A primeira falha vence.
  Future<Either<Falha, DadosPagina>> carregar(String filialId) async {
    final (estrutura, identidade, panfletos) = await (
      _estrutura.obter(filialId),
      _identidade.obter(),
      _panfletos.listar(filialId),
    ).wait;
    return switch ((estrutura, identidade, panfletos)) {
      (Failure(:final falha), _, _) ||
      (_, Failure(:final falha), _) ||
      (_, _, Failure(:final falha)) => Failure(falha),
      (
        Success(valor: final estrutura),
        Success(valor: final identidade),
        Success(valor: final panfletos),
      ) =>
        Success(
          DadosPagina(
            identidade: identidade,
            estrutura: estrutura,
            panfletoVigente: panfletos
                .where((p) => p.vigencia.situacao == SituacaoVigencia.vigente)
                .firstOrNull,
          ),
        ),
    };
  }

  Future<Either<Falha, EstruturaResponse>> publicar(
    String filialId,
    EstruturaRequest request,
  ) => _estrutura.salvar(filialId, request);
}
