import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/nada.dart';
import 'package:tabloide_core/src/requests/categoria_request.dart';
import 'package:tabloide_core/src/responses/categoria_response.dart';

abstract interface class CategoriaRepository {
  Future<Either<Falha, List<CategoriaResponse>>> listar(String filialId);

  Future<Either<Falha, CategoriaResponse>> criar(
    String filialId,
    CategoriaRequest request,
  );

  Future<Either<Falha, CategoriaResponse>> renomear(
    String filialId,
    String id,
    CategoriaRequest request,
  );

  Future<Either<Falha, Nada>> excluir(String filialId, String id);
}
