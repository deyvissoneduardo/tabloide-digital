import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/requests/estrutura_request.dart';
import 'package:tabloide_core/src/responses/estrutura_response.dart';

abstract interface class EstruturaRepository {
  Future<Either<Falha, EstruturaResponse>> obter(String filialId);

  Future<Either<Falha, EstruturaResponse>> salvar(
    String filialId,
    EstruturaRequest request,
  );
}
