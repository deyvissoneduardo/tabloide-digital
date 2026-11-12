import 'package:tabloide_core/tabloide_core.dart';

final class AcessosServiceApp {
  const AcessosServiceApp(this._repository);

  final AcessosRepository _repository;

  Future<Either<Falha, ResumoAcessosResponse>> resumo(
    PeriodoAcessos periodo, {
    String? filialId,
  }) => _repository.resumo(periodo, filialId: filialId);

  Future<Either<Falha, AcessosPanfletosResponse>> panfletos(
    String filialId,
    PeriodoAcessos periodo,
  ) => _repository.panfletos(filialId, periodo);
}
