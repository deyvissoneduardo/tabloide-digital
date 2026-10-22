import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/features/home/models/resumo_painel.dart';

/// Acesso aos dados da home do painel.
abstract interface class HomeRepository {
  /// Resumo da seção Início.
  Future<Either<Falha, ResumoPainel>> buscarResumo();
}
