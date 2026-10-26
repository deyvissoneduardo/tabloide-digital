import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/nada.dart';
import 'package:tabloide_core/src/either/tentar.dart';
import 'package:tabloide_core/src/features/produtos/repositories/produto_repository.dart';
import 'package:tabloide_core/src/features/vigencia/models/situacao_vigencia.dart';
import 'package:tabloide_core/src/http/rest_client.dart';
import 'package:tabloide_core/src/requests/editar_produto_request.dart';
import 'package:tabloide_core/src/requests/produto_request.dart';
import 'package:tabloide_core/src/responses/produto_response.dart';

const _porPagina = 100;

String _caminho(String filialId) => '/painel/filiais/$filialId/produtos';

final class ProdutoRepositoryApi implements ProdutoRepository {
  const ProdutoRepositoryApi(this._client);

  final RestClient _client;

  @override
  Future<Either<Falha, List<ProdutoResponse>>> listar(String filialId) async {
    final produtos = <ProdutoResponse>[];
    for (var pagina = 1; ; pagina++) {
      final resultado = await _pagina(filialId, pagina);
      switch (resultado) {
        case Failure(:final falha):
          return Failure(falha);
        case Success(valor: (:final itens, :final total)):
          produtos.addAll(itens);
          if (itens.isEmpty || produtos.length >= total) {
            return Success(List.unmodifiable(produtos));
          }
      }
    }
  }

  Future<Either<Falha, ({List<ProdutoResponse> itens, int total})>> _pagina(
    String filialId,
    int pagina,
  ) => _chamar(
    () => _client.get(
      _caminho(filialId),
      query: {
        'situacao': [
          SituacaoVigencia.vigente.codigo,
          SituacaoVigencia.agendado.codigo,
        ].join(','),
        'pagina': pagina,
        'porPagina': _porPagina,
      },
    ),
    (dados) => switch (dados) {
      {'itens': final List<dynamic> itens, 'total': final int total} => (
        itens: [for (final item in itens) ProdutoResponse.fromJson(item)],
        total: total,
      ),
      _ => throw const FormatException('Lista de produtos fora do formato'),
    },
  );

  @override
  Future<Either<Falha, ProdutoResponse>> obter(String filialId, String id) =>
      _chamar(
        () => _client.get('${_caminho(filialId)}/$id'),
        ProdutoResponse.fromJson,
      );

  @override
  Future<Either<Falha, ProdutoResponse>> criar(
    String filialId,
    ProdutoRequest request, {
    ArquivoProduto? foto,
  }) => _chamar(
    () => switch (foto) {
      (:final bytes, :final nome)? => _client.enviarArquivo(
        _caminho(filialId),
        campo: 'foto',
        bytes: bytes,
        nomeArquivo: nome,
        metodo: MetodoEnvio.post,
        campos: request.toCampos(),
      ),
      null => _client.post(_caminho(filialId), corpo: request.toJson()),
    },
    ProdutoResponse.fromJson,
  );

  @override
  Future<Either<Falha, ProdutoResponse>> editar(
    String filialId,
    String id,
    EditarProdutoRequest request,
  ) => _chamar(
    () => _client.patch('${_caminho(filialId)}/$id', corpo: request.toJson()),
    ProdutoResponse.fromJson,
  );

  @override
  Future<Either<Falha, ProdutoResponse>> trocarFoto(
    String filialId,
    String id,
    ArquivoProduto foto,
  ) => _chamar(
    () => _client.enviarArquivo(
      '${_caminho(filialId)}/$id/foto',
      campo: 'foto',
      bytes: foto.bytes,
      nomeArquivo: foto.nome,
    ),
    ProdutoResponse.fromJson,
  );

  @override
  Future<Either<Falha, ProdutoResponse>> removerFoto(
    String filialId,
    String id,
  ) => _chamar(
    () => _client.delete('${_caminho(filialId)}/$id/foto'),
    ProdutoResponse.fromJson,
  );

  @override
  Future<Either<Falha, Nada>> excluir(String filialId, String id) => _chamar(
    () => _client.delete('${_caminho(filialId)}/$id'),
    (_) => const Nada(),
  );

  Future<Either<Falha, T>> _chamar<T>(
    Future<RestResposta> Function() requisicao,
    T Function(Object? dados) converter,
  ) async {
    final resposta = await tentar(requisicao);
    return switch (resposta) {
      Failure(:final falha) => Failure(falha),
      Success(valor: RestResposta(status: 200 || 201 || 204, :final dados)) =>
        await tentar(() async => converter(dados)),
      Success(:final valor) => Failure(_falhaDa(valor)),
    };
  }

  Falha _falhaDa(RestResposta resposta) => switch (resposta.dados) {
    {
      'erro':
          {'codigo': final String codigo, 'mensagem': final String mensagem} &&
          final Map<dynamic, dynamic> erro,
    } =>
      FalhaApi(
        codigo: codigo,
        mensagem: mensagem,
        campos: _campos(erro['detalhes'], mensagem),
        detalhes: switch (erro['detalhes']) {
          final Map<dynamic, dynamic> detalhes => {
            for (final MapEntry(:key, :value) in detalhes.entries)
              '$key': value,
          },
          _ => const {},
        },
      ),
    _ => FalhaInesperada('HTTP ${resposta.status} sem corpo de erro'),
  };

  Map<String, List<String>> _campos(Object? detalhes, String mensagem) =>
      switch (detalhes) {
        {'campos': final Map<dynamic, dynamic> campos} => {
          for (final MapEntry(:key, :value) in campos.entries)
            if (value case final List<dynamic> mensagens)
              '$key': [
                for (final m in mensagens)
                  if (m is String) m,
              ],
        },
        {'campo': final String campo} => {
          campo: [mensagem],
        },
        _ => const {},
      };
}
