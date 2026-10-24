import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/features/auth/repositories/auth_repository.dart';
import 'package:tabloide_core/src/requests/login_request.dart';
import 'package:tabloide_core/src/responses/login_response.dart';
import 'package:tabloide_core/src/responses/lojista_response.dart';

final sessaoFake = LoginResponse(
  lojista: LojistaResponse(
    id: '0192f0a1-6c2e-7b10-9f3a-1c2d3e4f5a01',
    nomeFantasia: 'Mercado Bom Preço',
    nomeResponsavel: 'Ana Souza',
    email: 'ana@bompreco.com.br',
    whatsapp: '+5511987654321',
    cnpj: '11222333000181',
    status: 'AGUARDANDO_ATIVACAO',
    criadoEm: DateTime.utc(2026, 10, 18, 13),
  ),
  token: 'token-fake',
  expiraEm: DateTime.utc(2026, 10, 18, 21),
);

final class AuthRepositoryFake implements AuthRepository {
  AuthRepositoryFake({
    LoginResponse? sessao,
    this.falhaSimulada,
    this.atraso = Duration.zero,
  }) : sessao = sessao ?? sessaoFake;

  final LoginResponse sessao;

  final Falha? falhaSimulada;

  final Duration atraso;

  final pedidos = <LoginRequest>[];

  @override
  Future<Either<Falha, LoginResponse>> entrar(LoginRequest request) async {
    pedidos.add(request);
    await Future<void>.delayed(atraso);
    return switch (falhaSimulada) {
      final falha? => Failure(falha),
      null => Success(sessao),
    };
  }
}
