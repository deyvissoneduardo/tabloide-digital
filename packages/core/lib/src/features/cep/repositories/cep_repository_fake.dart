import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/features/cep/repositories/cep_repository.dart';
import 'package:tabloide_core/src/features/cep/repositories/cep_repository_via_cep.dart';
import 'package:tabloide_core/src/responses/cep_response.dart';

const cepFake = CepResponse(
  cep: '01001-000',
  logradouro: 'Praça da Sé',
  bairro: 'Sé',
  cidade: 'São Paulo',
  uf: 'SP',
);

const cepFakeCampinas = CepResponse(
  cep: '13010-111',
  logradouro: 'Rua das Flores',
  bairro: 'Centro',
  cidade: 'Campinas',
  uf: 'SP',
);

final class CepRepositoryFake implements CepRepository {
  CepRepositoryFake({
    Map<String, CepResponse>? ceps,
    this.falhaSimulada,
    this.atraso = Duration.zero,
  }) : ceps = ceps ?? {'01001000': cepFake, '13010111': cepFakeCampinas};

  final Map<String, CepResponse> ceps;

  Falha? falhaSimulada;

  final Duration atraso;

  final buscados = <String>[];

  @override
  Future<Either<Falha, CepResponse>> buscar(String cep) async {
    buscados.add(cep);
    await Future<void>.delayed(atraso);
    if (falhaSimulada case final falha?) return Failure(falha);
    return switch (ceps[cep]) {
      final endereco? => Success(endereco),
      null => const Failure(cepNaoEncontrado),
    };
  }
}
