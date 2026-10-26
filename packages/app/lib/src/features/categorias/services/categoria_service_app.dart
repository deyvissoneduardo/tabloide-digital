import 'package:tabloide_core/tabloide_core.dart';

final class CategoriaServiceApp {
  const CategoriaServiceApp(this._repository);

  final CategoriaRepository _repository;

  Future<Either<Falha, List<CategoriaResponse>>> listar(String filialId) =>
      _repository.listar(filialId);

  Future<Either<Falha, CategoriaResponse>> criar(
    String filialId,
    CategoriaRequest request,
  ) => _repository.criar(filialId, request);

  Future<Either<Falha, CategoriaResponse>> renomear(
    String filialId,
    String id,
    CategoriaRequest request,
  ) => _repository.renomear(filialId, id, request);

  Future<Either<Falha, Nada>> excluir(String filialId, String id) =>
      _repository.excluir(filialId, id);
}
