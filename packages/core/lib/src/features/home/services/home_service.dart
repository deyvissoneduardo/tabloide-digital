import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/features/home/models/resumo_painel.dart';

/// Contrato do service da home.
///
/// Fica no core porque o `HomeController` (compartilhado) depende dele; as
/// implementações ficam em `tabloide_app` e `tabloide_web` e recebem o
/// `HomeRepository` por injeção.
abstract interface class HomeService {
  /// Resumo da seção Início.
  Future<Either<Falha, ResumoPainel>> buscarResumo();
}
