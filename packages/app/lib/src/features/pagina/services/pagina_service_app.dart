import 'package:tabloide_core/tabloide_core.dart';

final class PaginaServiceApp {
  const PaginaServiceApp(
    this._estrutura,
    this._identidade,
    this._panfletos,
    this._configuracao,
  );

  final EstruturaRepository _estrutura;

  final IdentidadeRepository _identidade;

  final PanfletoRepository _panfletos;

  final ConfiguracaoPaginaRepository _configuracao;

  /// Estrutura, identidade, panfletos e aparência em paralelo; o vigente é o
  /// panfleto com situação VIGENTE. A primeira falha vence.
  Future<Either<Falha, DadosPagina>> carregar(String filialId) async {
    final (estrutura, identidade, panfletos, configuracao) = await (
      _estrutura.obter(filialId),
      _identidade.obter(),
      _panfletos.listar(filialId),
      _configuracao.obter(),
    ).wait;
    return switch ((estrutura, identidade, panfletos, configuracao)) {
      (Failure(:final falha), _, _, _) ||
      (_, Failure(:final falha), _, _) ||
      (_, _, Failure(:final falha), _) ||
      (_, _, _, Failure(:final falha)) => Failure(falha),
      (
        Success(valor: final estrutura),
        Success(valor: final identidade),
        Success(valor: final panfletos),
        Success(valor: final configuracao),
      ) =>
        Success(
          DadosPagina(
            identidade: identidade,
            estrutura: estrutura,
            panfletoVigente: panfletos
                .where((p) => p.vigencia.situacao == SituacaoVigencia.vigente)
                .firstOrNull,
            configuracao: configuracao,
          ),
        ),
    };
  }

  Future<Either<Falha, EstruturaResponse>> publicar(
    String filialId,
    EstruturaRequest request,
  ) => _estrutura.salvar(filialId, request);

  Future<Either<Falha, ConfiguracaoPaginaResponse>> editarAparencia(
    ConfiguracaoPaginaRequest request,
  ) => _configuracao.editar(request);

  Future<Either<Falha, ConfiguracaoPaginaResponse>> enviarLogoBanner({
    required List<int> bytes,
    required String nomeArquivo,
  }) => _configuracao.enviarLogoBanner(bytes: bytes, nomeArquivo: nomeArquivo);

  Future<Either<Falha, ConfiguracaoPaginaResponse>> removerLogoBanner() =>
      _configuracao.removerLogoBanner();

  Future<Either<Falha, ConfiguracaoPaginaResponse>> enviarFotoBanner({
    required List<int> bytes,
    required String nomeArquivo,
  }) => _configuracao.enviarFotoBanner(bytes: bytes, nomeArquivo: nomeArquivo);

  Future<Either<Falha, ConfiguracaoPaginaResponse>> removerFotoBanner() =>
      _configuracao.removerFotoBanner();
}
