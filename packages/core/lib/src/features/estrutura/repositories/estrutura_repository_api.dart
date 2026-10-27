import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/tentar.dart';
import 'package:tabloide_core/src/features/estrutura/repositories/estrutura_repository.dart';
import 'package:tabloide_core/src/http/rest_client.dart';
import 'package:tabloide_core/src/requests/estrutura_request.dart';
import 'package:tabloide_core/src/responses/estrutura_response.dart';

String _caminho(String filialId) => '/painel/filiais/$filialId/estrutura';

final class EstruturaRepositoryApi implements EstruturaRepository {
  const EstruturaRepositoryApi(this._client);

  final RestClient _client;

  @override
  Future<Either<Falha, EstruturaResponse>> obter(String filialId) =>
      _chamar(() => _client.get(_caminho(filialId)));

  @override
  Future<Either<Falha, EstruturaResponse>> salvar(
    String filialId,
    EstruturaRequest request,
  ) => _chamar(() => _client.put(_caminho(filialId), corpo: request.toJson()));

  Future<Either<Falha, EstruturaResponse>> _chamar(
    Future<RestResposta> Function() requisicao,
  ) async {
    final resposta = await tentar(requisicao);
    return switch (resposta) {
      Failure(:final falha) => Failure(falha),
      Success(valor: RestResposta(status: 200, :final dados)) => await tentar(
        () async => EstruturaResponse.fromJson(dados),
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
        campos: _campos(erro['detalhes']),
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

  Map<String, List<String>> _campos(Object? detalhes) => switch (detalhes) {
    {'campos': final Map<dynamic, dynamic> campos} => {
      for (final MapEntry(:key, :value) in campos.entries)
        if (value case final List<dynamic> mensagens)
          '$key': [
            for (final m in mensagens)
              if (m is String) m,
          ],
    },
    _ => const {},
  };
}
