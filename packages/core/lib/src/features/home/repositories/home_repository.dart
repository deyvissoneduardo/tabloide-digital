import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/features/home/models/resumo_painel.dart';

abstract interface class HomeRepository {
  Future<Either<Falha, ResumoPainel>> buscarResumo(List<String> filialIds);
}
