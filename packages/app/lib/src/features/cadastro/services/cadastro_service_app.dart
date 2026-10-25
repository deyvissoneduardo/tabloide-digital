import 'package:tabloide_core/tabloide_core.dart';

final class CadastroServiceApp {
  const CadastroServiceApp(this._repository, this._sessao);

  final CadastroRepository _repository;

  final Sessao _sessao;

  Future<Either<Falha, CadastroResponse>> cadastrar(
    CadastroRequest request,
  ) async {
    final resultado = await _repository.cadastrar(request);
    if (resultado case Success(:final valor)) {
      await _sessao.iniciar(token: valor.token, expiraEm: valor.expiraEm);
    }
    return resultado;
  }
}
