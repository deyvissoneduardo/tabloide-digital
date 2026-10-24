import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/tentar.dart';
import 'package:tabloide_core/src/features/home/models/resumo_painel.dart';
import 'package:tabloide_core/src/features/home/repositories/home_repository.dart';

final class HomeRepositoryFake implements HomeRepository {
  const HomeRepositoryFake({
    this.resumo = const ResumoPainel(
      filiais: 3,
      panfletosVigentes: 2,
      produtosVigentes: 48,
    ),
    this.atraso = const Duration(milliseconds: 400),
    this.falhaSimulada,
  });

  final ResumoPainel resumo;

  final Duration atraso;

  final Falha? falhaSimulada;

  @override
  Future<Either<Falha, ResumoPainel>> buscarResumo() async {
    final falha = falhaSimulada;
    if (falha != null) {
      await Future<void>.delayed(atraso);
      return Failure(falha);
    }
    return tentar(() async {
      await Future<void>.delayed(atraso);
      return resumo;
    });
  }
}
