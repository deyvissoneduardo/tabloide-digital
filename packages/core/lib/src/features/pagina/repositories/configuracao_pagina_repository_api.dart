import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/tentar.dart';
import 'package:tabloide_core/src/features/pagina/repositories/configuracao_pagina_repository.dart';
import 'package:tabloide_core/src/http/rest_client.dart';
import 'package:tabloide_core/src/requests/configuracao_pagina_request.dart';
import 'package:tabloide_core/src/responses/configuracao_pagina_response.dart';

const _caminho = '/painel/lojista/pagina';

const _caminhoLogo = '$_caminho/banner/logo';

const _caminhoFoto = '$_caminho/banner/foto';

final class ConfiguracaoPaginaRepositoryApi
    implements ConfiguracaoPaginaRepository {
  const ConfiguracaoPaginaRepositoryApi(this._client);

  final RestClient _client;

  @override
  Future<Either<Falha, ConfiguracaoPaginaResponse>> obter() =>
      _chamar(() => _client.get(_caminho));

  @override
  Future<Either<Falha, ConfiguracaoPaginaResponse>> editar(
    ConfiguracaoPaginaRequest request,
  ) => _chamar(() => _client.patch(_caminho, corpo: request.toJson()));

  @override
  Future<Either<Falha, ConfiguracaoPaginaResponse>> enviarLogoBanner({
    required List<int> bytes,
    required String nomeArquivo,
  }) => _enviar(_caminhoLogo, bytes, nomeArquivo);

  @override
  Future<Either<Falha, ConfiguracaoPaginaResponse>> removerLogoBanner() =>
      _chamar(() => _client.delete(_caminhoLogo));

  @override
  Future<Either<Falha, ConfiguracaoPaginaResponse>> enviarFotoBanner({
    required List<int> bytes,
    required String nomeArquivo,
  }) => _enviar(_caminhoFoto, bytes, nomeArquivo);

  @override
  Future<Either<Falha, ConfiguracaoPaginaResponse>> removerFotoBanner() =>
      _chamar(() => _client.delete(_caminhoFoto));

  Future<Either<Falha, ConfiguracaoPaginaResponse>> _enviar(
    String caminho,
    List<int> bytes,
    String nomeArquivo,
  ) => _chamar(
    () => _client.enviarArquivo(
      caminho,
      campo: 'imagem',
      bytes: bytes,
      nomeArquivo: nomeArquivo,
    ),
  );

  Future<Either<Falha, ConfiguracaoPaginaResponse>> _chamar(
    Future<RestResposta> Function() requisicao,
  ) async {
    final resposta = await tentar(requisicao);
    return switch (resposta) {
      Failure(:final falha) => Failure(falha),
      Success(valor: RestResposta(status: 200, :final dados)) => await tentar(
        () async => ConfiguracaoPaginaResponse.fromJson(dados),
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
