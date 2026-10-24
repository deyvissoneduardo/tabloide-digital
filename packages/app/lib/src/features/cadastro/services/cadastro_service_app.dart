import 'package:tabloide_core/tabloide_core.dart';

final class CadastroServiceApp {
  const CadastroServiceApp(this._repository);

  final CadastroRepository _repository;

  Future<Either<Falha, CadastroResponse>> cadastrar(CadastroRequest request) =>
      _repository.cadastrar(request);
}
