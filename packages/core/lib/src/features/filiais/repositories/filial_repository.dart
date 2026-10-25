import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/nada.dart';
import 'package:tabloide_core/src/requests/filial_request.dart';
import 'package:tabloide_core/src/responses/filial_response.dart';

abstract interface class FilialRepository {
  Future<Either<Falha, List<FilialResponse>>> listar();

  Future<Either<Falha, FilialResponse>> obter(String id);

  Future<Either<Falha, FilialResponse>> criar(FilialRequest request);

  Future<Either<Falha, FilialResponse>> editar(
    String id,
    FilialRequest request,
  );

  Future<Either<Falha, Nada>> excluir(String id);
}
