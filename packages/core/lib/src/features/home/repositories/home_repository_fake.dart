import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/tentar.dart';
import 'package:tabloide_core/src/features/home/models/resumo_painel.dart';
import 'package:tabloide_core/src/features/home/repositories/home_repository.dart';

/// [HomeRepository] em memória, usado até existir integração com a API.
final class HomeRepositoryFake implements HomeRepository {
  /// Cria o fake; [falhaSimulada] faz toda chamada falhar.
  const HomeRepositoryFake({
    this.resumo = const ResumoPainel(
      filiais: 3,
      panfletosVigentes: 2,
      produtosVigentes: 48,
    ),
    this.atraso = const Duration(milliseconds: 400),
    this.falhaSimulada,
  });

  /// Resumo devolvido em caso de sucesso.
  final ResumoPainel resumo;

  /// Simula a latência da rede.
  final Duration atraso;

  /// Quando informada, toda chamada devolve esta falha.
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
