import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/nada.dart';
import 'package:tabloide_core/src/either/tentar.dart';
import 'package:tabloide_core/src/features/categorias/repositories/categoria_repository.dart';
import 'package:tabloide_core/src/http/rest_client.dart';
import 'package:tabloide_core/src/requests/categoria_request.dart';
import 'package:tabloide_core/src/responses/categoria_response.dart';

String _caminho(String filialId) => '/painel/filiais/$filialId/categorias';

final class CategoriaRepositoryApi implements CategoriaRepository {
  const CategoriaRepositoryApi(this._client);

  final RestClient _client;

  @override
  Future<Either<Falha, List<CategoriaResponse>>> listar(String filialId) =>
      _chamar(
        () => _client.get(_caminho(filialId)),
        (dados) => switch (dados) {
          {'itens': final List<dynamic> itens} => [
            for (final item in itens) CategoriaResponse.fromJson(item),
          ],
          _ => throw const FormatException(
            'Lista de categorias fora do formato',
          ),
        },
      );

  @override
  Future<Either<Falha, CategoriaResponse>> criar(
    String filialId,
    CategoriaRequest request,
  ) => _chamar(
    () => _client.post(_caminho(filialId), corpo: request.toJson()),
    CategoriaResponse.fromJson,
  );

  @override
  Future<Either<Falha, CategoriaResponse>> renomear(
    String filialId,
    String id,
    CategoriaRequest request,
  ) => _chamar(
    () => _client.patch('${_caminho(filialId)}/$id', corpo: request.toJson()),
    CategoriaResponse.fromJson,
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
