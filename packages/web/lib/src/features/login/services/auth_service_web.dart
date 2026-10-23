import 'package:tabloide_core/tabloide_core.dart';

/// Autenticação na web: depende só do contrato [AuthRepository].
///
/// Regras exclusivas do navegador (ex.: guardar a sessão no `localStorage`) entram
/// aqui, sem mudar o repository nem o controller.
final class AuthServiceWeb {
  /// Cria o service com o repository injetado.
  const AuthServiceWeb(this._repository);

  final AuthRepository _repository;

  /// Abre a sessão com as credenciais do [request].
  Future<Either<Falha, LoginResponse>> entrar(LoginRequest request) =>
      _repository.entrar(request);
}
