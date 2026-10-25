import 'package:tabloide_core/tabloide_core.dart';

final class AuthServiceWeb {
  const AuthServiceWeb(this._repository, this._sessao);

  final AuthRepository _repository;

  final Sessao _sessao;

  Future<Either<Falha, LoginResponse>> entrar(LoginRequest request) async {
    final resultado = await _repository.entrar(request);
    if (resultado case Success(:final valor)) {
      await _sessao.iniciar(token: valor.token, expiraEm: valor.expiraEm);
    }
    return resultado;
  }

  Future<Either<Falha, Nada>> sair() async {
    await _sessao.encerrar();
    return const Success(Nada());
  }
}
