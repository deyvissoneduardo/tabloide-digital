import 'package:tabloide_core/tabloide_core.dart';

final class AuthServiceApp {
  const AuthServiceApp(this._repository);

  final AuthRepository _repository;

  Future<Either<Falha, LoginResponse>> entrar(LoginRequest request) =>
      _repository.entrar(request);
}
