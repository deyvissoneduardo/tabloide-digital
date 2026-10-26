import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/nada.dart';
import 'package:tabloide_core/src/requests/panfleto_request.dart';
import 'package:tabloide_core/src/responses/panfleto_response.dart';

abstract interface class PanfletoRepository {
  Future<Either<Falha, List<PanfletoResponse>>> listar(String filialId);

  Future<Either<Falha, PanfletoResponse>> obter(String filialId, String id);

  Future<Either<Falha, PanfletoResponse>> criar(
    String filialId,
    PanfletoRequest request, {
    required List<int> bytes,
    required String nomeArquivo,
  });

  Future<Either<Falha, PanfletoResponse>> editar(
    String filialId,
    String id,
    PanfletoRequest request,
  );

  Future<Either<Falha, PanfletoResponse>> trocarImagem(
    String filialId,
    String id, {
    required List<int> bytes,
    required String nomeArquivo,
  });

  Future<Either<Falha, Nada>> excluir(String filialId, String id);
}
