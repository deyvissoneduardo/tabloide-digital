import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';

/// Executa [acao] e converte qualquer exceção em [FalhaInesperada].
///
/// Repositories usam isto para nunca deixar exceção vazar para o service.
Future<Either<Falha, S>> tentar<S>(Future<S> Function() acao) async {
  try {
    return Success(await acao());
  } on Object catch (erro) {
    return Failure(FalhaInesperada(erro));
  }
}
