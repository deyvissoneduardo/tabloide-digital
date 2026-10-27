import 'dart:typed_data';

import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/nada.dart';
import 'package:tabloide_core/src/either/tentar.dart';
import 'package:tabloide_core/src/features/filiais/repositories/filial_repository.dart';
import 'package:tabloide_core/src/http/rest_client.dart';
import 'package:tabloide_core/src/requests/filial_request.dart';
import 'package:tabloide_core/src/responses/filial_response.dart';

const _caminho = '/painel/filiais';

final class FilialRepositoryApi implements FilialRepository {
  const FilialRepositoryApi(this._client);

  final RestClient _client;

  @override
  Future<Either<Falha, List<FilialResponse>>> listar() => _chamar(
    () => _client.get(_caminho, query: {'pagina': 1, 'porPagina': 50}),
    (dados) => switch (dados) {
      {'itens': final List<dynamic> itens} => [
        for (final item in itens) FilialResponse.fromJson(item),
      ],
      _ => throw const FormatException('Lista de filiais fora do formato'),
    },
  );

  @override
  Future<Either<Falha, FilialResponse>> obter(String id) =>
      _chamar(() => _client.get('$_caminho/$id'), FilialResponse.fromJson);

  @override
  Future<Either<Falha, FilialResponse>> criar(FilialRequest request) => _chamar(
    () => _client.post(_caminho, corpo: request.toJson()),
    FilialResponse.fromJson,
  );

  @override
  Future<Either<Falha, FilialResponse>> editar(
    String id,
    FilialRequest request,
  ) => _chamar(
    () => _client.patch('$_caminho/$id', corpo: request.toJson()),
    FilialResponse.fromJson,
  );

  @override
  Future<Either<Falha, Nada>> excluir(String id) =>
      _chamar(() => _client.delete('$_caminho/$id'), (_) => const Nada());

  @override
  Future<Either<Falha, Uint8List>> qrCode(String id) => _chamar(
    () => _client.baixar(
      '$_caminho/$id/qrcode',
      query: {'formato': 'png', 'tamanho': 512},
    ),
    (dados) => dados! as Uint8List,
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
