import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/tentar.dart';
import 'package:tabloide_core/src/features/home/models/resumo_filial.dart';
import 'package:tabloide_core/src/features/home/models/resumo_painel.dart';
import 'package:tabloide_core/src/features/home/repositories/home_repository.dart';

final class HomeRepositoryFake implements HomeRepository {
  const HomeRepositoryFake({
    this.resumo = const ResumoPainel(
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
  Future<Either<Falha, ResumoPainel>> buscarResumo(
    List<String> filialIds,
  ) async {
    final falha = falhaSimulada;
    if (falha != null) {
      await Future<void>.delayed(atraso);
      return Failure(falha);
    }
    return tentar(() async {
      await Future<void>.delayed(atraso);
      // Sem porFilial definido: a 1ª filial leva os totais.
      if (resumo.porFilial.isNotEmpty) return resumo;
      return ResumoPainel(
        panfletosVigentes: resumo.panfletosVigentes,
        produtosVigentes: resumo.produtosVigentes,
        porFilial: [
          for (final (i, id) in filialIds.indexed)
            ResumoFilial(
              filialId: id,
              panfletosVigentes: i == 0 ? resumo.panfletosVigentes : 0,
              produtosVigentes: i == 0 ? resumo.produtosVigentes : 0,
            ),
        ],
      );
    });
  }
}
