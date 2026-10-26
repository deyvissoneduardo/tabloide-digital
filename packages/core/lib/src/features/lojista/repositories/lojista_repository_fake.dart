import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/features/lojista/repositories/lojista_repository.dart';
import 'package:tabloide_core/src/requests/lojista_request.dart';
import 'package:tabloide_core/src/responses/lojista_response.dart';

final lojistaFake = LojistaResponse(
  id: '0192f0a1-6c2e-7b10-9f3a-1c2d3e4f5a01',
  nomeFantasia: 'Mercado Bom Preço',
  nomeResponsavel: 'Ana Souza',
  email: 'ana@bompreco.com.br',
  whatsapp: '+5511987654321',
  cnpj: '77343168000124',
  status: 'ATIVO',
  criadoEm: DateTime.utc(2026, 10, 18, 13),
);

final class LojistaRepositoryFake implements LojistaRepository {
  LojistaRepositoryFake({
    LojistaResponse? lojista,
    this.falhaSimulada,
    this.atraso = Duration.zero,
  }) : lojista = lojista ?? lojistaFake;

  LojistaResponse lojista;

  Falha? falhaSimulada;

  final Duration atraso;

  final pedidos = <LojistaRequest>[];

  @override
  Future<Either<Falha, LojistaResponse>> obter() => _responder(() => lojista);

  @override
  Future<Either<Falha, LojistaResponse>> editar(LojistaRequest request) {
    pedidos.add(request);
    return _responder(
      () => lojista = LojistaResponse(
        id: lojista.id,
        nomeFantasia: request.nomeFantasia,
        nomeResponsavel: request.nomeResponsavel,
        email: lojista.email,
        whatsapp: '+55${request.whatsapp}',
        cnpj: request.cnpj,
        status: lojista.status,
        criadoEm: lojista.criadoEm,
      ),
    );
  }

  Future<Either<Falha, T>> _responder<T>(T Function() acao) async {
    await Future<void>.delayed(atraso);
    return switch (falhaSimulada) {
      final falha? => Failure(falha),
      null => Success(acao()),
    };
  }
}
