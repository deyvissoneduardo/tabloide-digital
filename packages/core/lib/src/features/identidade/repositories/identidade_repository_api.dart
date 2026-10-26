import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/tentar.dart';
import 'package:tabloide_core/src/features/identidade/repositories/identidade_repository.dart';
import 'package:tabloide_core/src/http/rest_client.dart';
import 'package:tabloide_core/src/requests/identidade_request.dart';
import 'package:tabloide_core/src/responses/identidade_response.dart';

const _caminho = '/painel/lojista/identidade';

const _caminhoLogo = '/painel/lojista/logo';

final class IdentidadeRepositoryApi implements IdentidadeRepository {
  const IdentidadeRepositoryApi(this._client);

  final RestClient _client;

  @override
  Future<Either<Falha, IdentidadeResponse>> obter() =>
      _chamar(() => _client.get(_caminho));

  @override
  Future<Either<Falha, IdentidadeResponse>> editar(IdentidadeRequest request) =>
      _chamar(() => _client.patch(_caminho, corpo: request.toJson()));

  @override
  Future<Either<Falha, IdentidadeResponse>> enviarLogo({
    required List<int> bytes,
    required String nomeArquivo,
  }) => _chamar(
    () => _client.enviarArquivo(
      _caminhoLogo,
      campo: 'imagem',
      bytes: bytes,
      nomeArquivo: nomeArquivo,
    ),
  );

  Future<Either<Falha, IdentidadeResponse>> _chamar(
    Future<RestResposta> Function() requisicao,
  ) async {
    final resposta = await tentar(requisicao);
    return switch (resposta) {
      Failure(:final falha) => Failure(falha),
      Success(valor: RestResposta(status: 200, :final dados)) => await tentar(
        () async => IdentidadeResponse.fromJson(dados),
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
