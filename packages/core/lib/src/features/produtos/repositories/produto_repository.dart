import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/nada.dart';
import 'package:tabloide_core/src/requests/editar_produto_request.dart';
import 'package:tabloide_core/src/requests/produto_request.dart';
import 'package:tabloide_core/src/responses/produto_response.dart';

typedef ArquivoProduto = ({List<int> bytes, String nome});

abstract interface class ProdutoRepository {
  Future<Either<Falha, List<ProdutoResponse>>> listar(String filialId);

  Future<Either<Falha, ProdutoResponse>> obter(String filialId, String id);

  Future<Either<Falha, ProdutoResponse>> criar(
    String filialId,
    ProdutoRequest request, {
    ArquivoProduto? foto,
  });

  Future<Either<Falha, ProdutoResponse>> editar(
    String filialId,
    String id,
    EditarProdutoRequest request,
  );

  Future<Either<Falha, ProdutoResponse>> trocarFoto(
    String filialId,
    String id,
    ArquivoProduto foto,
  );

  Future<Either<Falha, ProdutoResponse>> removerFoto(
    String filialId,
    String id,
  );

  Future<Either<Falha, Nada>> excluir(String filialId, String id);
}
