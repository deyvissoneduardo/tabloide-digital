import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/requests/login_request.dart';
import 'package:tabloide_core/src/responses/login_response.dart';

/// Acesso à autenticação do lojista.
abstract interface class AuthRepository {
  /// Abre a sessão com as credenciais do [request].
  ///
  /// Credenciais erradas ou excesso de tentativas voltam como `FalhaApi`,
  /// com a mensagem da API.
  Future<Either<Falha, LoginResponse>> entrar(LoginRequest request);
}
