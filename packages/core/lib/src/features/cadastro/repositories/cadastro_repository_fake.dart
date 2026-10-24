import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/features/auth/repositories/auth_repository_fake.dart';
import 'package:tabloide_core/src/features/cadastro/repositories/cadastro_repository.dart';
import 'package:tabloide_core/src/requests/cadastro_request.dart';
import 'package:tabloide_core/src/responses/cadastro_response.dart';

final cadastroFake = CadastroResponse(
  lojista: sessaoFake.lojista,
  token: 'token-fake',
  expiraEm: sessaoFake.expiraEm,
);

final class CadastroRepositoryFake implements CadastroRepository {
  CadastroRepositoryFake({
    CadastroResponse? conta,
    this.falhaSimulada,
    this.atraso = Duration.zero,
  }) : conta = conta ?? cadastroFake;

  final CadastroResponse conta;

  final Falha? falhaSimulada;

  final Duration atraso;

  final pedidos = <CadastroRequest>[];

  @override
  Future<Either<Falha, CadastroResponse>> cadastrar(
    CadastroRequest request,
  ) async {
    pedidos.add(request);
    await Future<void>.delayed(atraso);
    return switch (falhaSimulada) {
      final falha? => Failure(falha),
      null => Success(conta),
    };
  }
}
