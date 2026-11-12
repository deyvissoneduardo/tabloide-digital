import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/tentar.dart';
import 'package:tabloide_core/src/features/acessos/models/periodo_acessos.dart';
import 'package:tabloide_core/src/features/acessos/repositories/acessos_repository.dart';
import 'package:tabloide_core/src/http/rest_client.dart';
import 'package:tabloide_core/src/requests/periodo_acessos_query.dart';
import 'package:tabloide_core/src/responses/acessos_panfletos_response.dart';
import 'package:tabloide_core/src/responses/resumo_acessos_response.dart';

final class AcessosRepositoryApi implements AcessosRepository {
  const AcessosRepositoryApi(this._client);

  final RestClient _client;

  @override
  Future<Either<Falha, ResumoAcessosResponse>> resumo(
    PeriodoAcessos periodo, {
    String? filialId,
  }) => _chamar(
    () => _client.get(
      '/painel/acessos',
      query: {...periodo.toQuery(), 'filialId': ?filialId},
    ),
    ResumoAcessosResponse.fromJson,
  );

  @override
  Future<Either<Falha, AcessosPanfletosResponse>> panfletos(
    String filialId,
    PeriodoAcessos periodo,
  ) => _chamar(
    () => _client.get(
      '/painel/filiais/$filialId/acessos/panfletos',
      query: periodo.toQuery(),
    ),
    AcessosPanfletosResponse.fromJson,
  );

  Future<Either<Falha, T>> _chamar<T>(
    Future<RestResposta> Function() requisicao,
    T Function(Object? dados) converter,
  ) async {
    final resposta = await tentar(requisicao);
    return switch (resposta) {
      Failure(:final falha) => Failure(falha),
      Success(valor: RestResposta(status: 200, :final dados)) => await tentar(
        () async => converter(dados),
      ),
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
}
