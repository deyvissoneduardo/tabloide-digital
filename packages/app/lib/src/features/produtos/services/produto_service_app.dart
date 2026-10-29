import 'package:tabloide_core/tabloide_core.dart';

final class ProdutoServiceApp {
  const ProdutoServiceApp(this._repository);

  final ProdutoRepository _repository;

  Future<Either<Falha, List<ProdutoResponse>>> listar(String filialId) =>
      _repository.listar(filialId);

  /// Produto completo para abrir o formulário a partir do editor da página
  /// (U17).
  Future<Either<Falha, ProdutoResponse>> obter(String filialId, String id) =>
      _repository.obter(filialId, id);

  Future<Either<Falha, ProdutoResponse>> criar(
    String filialId,
    ProdutoRequest request, {
    ArquivoProduto? foto,
  }) => _repository.criar(filialId, request, foto: foto);

  Future<Either<Falha, ProdutoResponse>> editar(
    String filialId,
    String id,
    EditarProdutoRequest request,
  ) => _repository.editar(filialId, id, request);

  Future<Either<Falha, ProdutoResponse>> trocarFoto(
    String filialId,
    String id,
    ArquivoProduto foto,
  ) => _repository.trocarFoto(filialId, id, foto);

  Future<Either<Falha, ProdutoResponse>> removerFoto(
    String filialId,
    String id,
  ) => _repository.removerFoto(filialId, id);

  Future<Either<Falha, Nada>> excluir(String filialId, String id) =>
      _repository.excluir(filialId, id);
}
