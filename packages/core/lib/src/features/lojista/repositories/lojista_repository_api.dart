import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/tentar.dart';
import 'package:tabloide_core/src/features/lojista/repositories/lojista_repository.dart';
import 'package:tabloide_core/src/http/rest_client.dart';
import 'package:tabloide_core/src/requests/lojista_request.dart';
import 'package:tabloide_core/src/responses/lojista_response.dart';

const _caminho = '/painel/lojista';

final class LojistaRepositoryApi implements LojistaRepository {
  const LojistaRepositoryApi(this._client);

  final RestClient _client;

  @override
  Future<Either<Falha, LojistaResponse>> obter() =>
      _chamar(() => _client.get(_caminho));

  @override
  Future<Either<Falha, LojistaResponse>> editar(LojistaRequest request) =>
      _chamar(() => _client.patch(_caminho, corpo: request.toJson()));

  Future<Either<Falha, LojistaResponse>> _chamar(
    Future<RestResposta> Function() requisicao,
  ) async {
    final resposta = await tentar(requisicao);
    return switch (resposta) {
      Failure(:final falha) => Failure(falha),
      Success(valor: RestResposta(status: 200, :final dados)) => await tentar(
        () async => LojistaResponse.fromJson(dados),
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
        campos: _campos(erro['detalhes'], mensagem),
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
