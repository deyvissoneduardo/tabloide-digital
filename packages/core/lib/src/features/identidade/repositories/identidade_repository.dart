import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/requests/identidade_request.dart';
import 'package:tabloide_core/src/responses/identidade_response.dart';

abstract interface class IdentidadeRepository {
  Future<Either<Falha, IdentidadeResponse>> obter();

  Future<Either<Falha, IdentidadeResponse>> editar(IdentidadeRequest request);

  Future<Either<Falha, IdentidadeResponse>> enviarLogo({
    required List<int> bytes,
    required String nomeArquivo,
  });
}
