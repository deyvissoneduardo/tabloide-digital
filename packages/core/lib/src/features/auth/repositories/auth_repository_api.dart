import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/tentar.dart';
import 'package:tabloide_core/src/features/auth/repositories/auth_repository.dart';
import 'package:tabloide_core/src/http/rest_client.dart';
import 'package:tabloide_core/src/requests/login_request.dart';
import 'package:tabloide_core/src/responses/login_response.dart';

/// [AuthRepository] sobre a API do Tabloide (`POST /auth/login`).
final class AuthRepositoryApi implements AuthRepository {
  /// Cria o repository com o [RestClient] injetado.
  const AuthRepositoryApi(this._client);

  final RestClient _client;

  @override
  Future<Either<Falha, LoginResponse>> entrar(LoginRequest request) async {
    final resposta = await tentar(
      () => _client.post('/auth/login', corpo: request.toJson()),
    );
    return switch (resposta) {
      Failure(:final falha) => Failure(falha),
      Success(valor: RestResposta(status: 200 || 201, :final dados)) =>
        await tentar(() async => LoginResponse.fromJson(dados)),
      Success(:final valor) => Failure(_falhaDa(valor)),
    };
  }

  /// Lê o corpo `{"erro": {"codigo", "mensagem"}}` da API.
  Falha _falhaDa(RestResposta resposta) => switch (resposta.dados) {
    {
      'erro': {
        'codigo': final String codigo,
        'mensagem': final String mensagem,
      },
    } =>
      FalhaApi(codigo: codigo, mensagem: mensagem),
    _ => FalhaInesperada('HTTP ${resposta.status} sem corpo de erro'),
  };
}
