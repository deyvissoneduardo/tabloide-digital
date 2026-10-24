import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/http/rest_client.dart';

Future<Either<Falha, S>> tentar<S>(Future<S> Function() acao) async {
  try {
    return Success(await acao());
  } on ErroSemConexao {
    return const Failure(FalhaSemConexao());
  } on Object catch (erro) {
    return Failure(FalhaInesperada(erro));
  }
}
