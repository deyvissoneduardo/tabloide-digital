import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/responses/cep_response.dart';

abstract interface class CepRepository {
  Future<Either<Falha, CepResponse>> buscar(String cep);
}
