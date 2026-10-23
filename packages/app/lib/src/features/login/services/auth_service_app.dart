import 'package:tabloide_core/tabloide_core.dart';

/// Autenticação no app: depende só do contrato [AuthRepository].
///
/// Regras exclusivas do mobile (ex.: guardar a sessão no aparelho) entram
/// aqui, sem mudar o repository nem o controller.
final class AuthServiceApp {
  /// Cria o service com o repository injetado.
  const AuthServiceApp(this._repository);

  final AuthRepository _repository;

  /// Abre a sessão com as credenciais do [request].
  Future<Either<Falha, LoginResponse>> entrar(LoginRequest request) =>
      _repository.entrar(request);
}
