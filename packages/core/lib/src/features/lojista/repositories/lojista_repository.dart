import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/requests/lojista_request.dart';
import 'package:tabloide_core/src/responses/lojista_response.dart';

abstract interface class LojistaRepository {
  Future<Either<Falha, LojistaResponse>> obter();

  Future<Either<Falha, LojistaResponse>> editar(LojistaRequest request);
}
