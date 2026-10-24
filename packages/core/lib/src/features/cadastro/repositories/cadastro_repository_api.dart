import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/tentar.dart';
import 'package:tabloide_core/src/features/cadastro/repositories/cadastro_repository.dart';
import 'package:tabloide_core/src/http/rest_client.dart';
import 'package:tabloide_core/src/requests/cadastro_request.dart';
import 'package:tabloide_core/src/responses/cadastro_response.dart';

final class CadastroRepositoryApi implements CadastroRepository {
  const CadastroRepositoryApi(this._client);

  final RestClient _client;

  @override
  Future<Either<Falha, CadastroResponse>> cadastrar(
    CadastroRequest request,
  ) async {
    final resposta = await tentar(
      () => _client.post('/auth/cadastro', corpo: request.toJson()),
    );
    return switch (resposta) {
      Failure(:final falha) => Failure(falha),
      Success(valor: RestResposta(status: 200 || 201, :final dados)) =>
        await tentar(() async => CadastroResponse.fromJson(dados)),
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
        campos: codigo == 'EMAIL_JA_CADASTRADO'
            ? {
                'email': [mensagem],
              }
            : _campos(erro['detalhes']),
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
