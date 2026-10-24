import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/requests/cadastro_request.dart';
import 'package:tabloide_core/src/responses/cadastro_response.dart';

abstract interface class CadastroRepository {
  Future<Either<Falha, CadastroResponse>> cadastrar(CadastroRequest request);
}
