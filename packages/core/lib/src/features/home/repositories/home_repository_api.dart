import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/tentar.dart';
import 'package:tabloide_core/src/features/home/models/resumo_painel.dart';
import 'package:tabloide_core/src/features/home/repositories/home_repository.dart';
import 'package:tabloide_core/src/features/vigencia/models/situacao_vigencia.dart';
import 'package:tabloide_core/src/http/rest_client.dart';

final class HomeRepositoryApi implements HomeRepository {
  const HomeRepositoryApi(this._client);

  final RestClient _client;

  @override
  Future<Either<Falha, ResumoPainel>> buscarResumo(
    List<String> filialIds,
  ) async {
    final contagens = await Future.wait([
      for (final id in filialIds) ...[
        _contarVigentes('/painel/filiais/$id/panfletos'),
        _contarVigentes('/painel/filiais/$id/produtos'),
      ],
    ]);
    var panfletos = 0;
    var produtos = 0;
    for (final (i, contagem) in contagens.indexed) {
      switch (contagem) {
        case Failure(:final falha):
          return Failure(falha);
        case Success(:final valor) when i.isEven:
          panfletos += valor;
        case Success(:final valor):
          produtos += valor;
      }
    }
    return Success(
      ResumoPainel(panfletosVigentes: panfletos, produtosVigentes: produtos),
    );
  }

  Future<Either<Falha, int>> _contarVigentes(String caminho) => _chamar(
    () => _client.get(
      caminho,
      query: {
        'situacao': SituacaoVigencia.vigente.codigo,
        'pagina': 1,
        'porPagina': 1,
      },
    ),
    (dados) => switch (dados) {
      {'total': final int total} => total,
      _ => throw const FormatException('Total da listagem fora do formato'),
    },
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
