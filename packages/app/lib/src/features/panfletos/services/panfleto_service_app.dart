import 'package:tabloide_core/tabloide_core.dart';

final class PanfletoServiceApp {
  const PanfletoServiceApp(this._repository);

  final PanfletoRepository _repository;

  Future<Either<Falha, List<PanfletoResponse>>> listar(String filialId) =>
      _repository.listar(filialId);

  Future<Either<Falha, PanfletoResponse>> criar(
    String filialId,
    PanfletoRequest request, {
    required List<int> bytes,
    required String nomeArquivo,
  }) => _repository.criar(
    filialId,
    request,
    bytes: bytes,
    nomeArquivo: nomeArquivo,
  );

  Future<Either<Falha, PanfletoResponse>> editar(
    String filialId,
    String id,
    PanfletoRequest request,
  ) => _repository.editar(filialId, id, request);

  Future<Either<Falha, PanfletoResponse>> trocarImagem(
    String filialId,
    String id, {
    required List<int> bytes,
    required String nomeArquivo,
  }) => _repository.trocarImagem(
    filialId,
    id,
    bytes: bytes,
    nomeArquivo: nomeArquivo,
  );

  Future<Either<Falha, Nada>> excluir(String filialId, String id) =>
      _repository.excluir(filialId, id);
}
