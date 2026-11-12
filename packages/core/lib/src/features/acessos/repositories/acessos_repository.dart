import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/features/acessos/models/periodo_acessos.dart';
import 'package:tabloide_core/src/responses/acessos_panfletos_response.dart';
import 'package:tabloide_core/src/responses/resumo_acessos_response.dart';

abstract interface class AcessosRepository {
  Future<Either<Falha, ResumoAcessosResponse>> resumo(
    PeriodoAcessos periodo, {
    String? filialId,
  });

  Future<Either<Falha, AcessosPanfletosResponse>> panfletos(
    String filialId,
    PeriodoAcessos periodo,
  );
}
