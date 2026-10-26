import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/features/identidade/repositories/identidade_repository.dart';
import 'package:tabloide_core/src/requests/identidade_request.dart';
import 'package:tabloide_core/src/responses/identidade_response.dart';

const identidadeFake = IdentidadeResponse(
  nomeFantasia: 'Mercado Bom Preço',
  corPrimaria: '#C8102E',
  corSecundaria: '#FFD100',
  urlLogo:
      'https://xyz.supabase.co/storage/v1/object/public/midia/'
      '0192f0a1-6c2e-7b10-9f3a-1c2d3e4f5a01/logo/0192f0e0.webp',
);

final class IdentidadeRepositoryFake implements IdentidadeRepository {
  IdentidadeRepositoryFake({
    this.identidade = identidadeFake,
    this.falhaSimulada,
    this.atraso = Duration.zero,
  });

  IdentidadeResponse identidade;

  Falha? falhaSimulada;

  final Duration atraso;

  final pedidos = <IdentidadeRequest>[];

  final logosEnviados = <String>[];

  @override
  Future<Either<Falha, IdentidadeResponse>> obter() =>
      _responder(() => identidade);

  @override
  Future<Either<Falha, IdentidadeResponse>> editar(IdentidadeRequest request) {
    pedidos.add(request);
    return _responder(
      () => identidade = IdentidadeResponse(
        nomeFantasia: request.nomeFantasia,
        corPrimaria: request.corPrimaria?.toUpperCase(),
        corSecundaria: request.corSecundaria?.toUpperCase(),
        urlLogo: identidade.urlLogo,
      ),
    );
  }

  @override
  Future<Either<Falha, IdentidadeResponse>> enviarLogo({
    required List<int> bytes,
    required String nomeArquivo,
  }) {
    logosEnviados.add(nomeArquivo);
    return _responder(
      () => identidade = IdentidadeResponse(
        nomeFantasia: identidade.nomeFantasia,
        corPrimaria: identidade.corPrimaria,
        corSecundaria: identidade.corSecundaria,
        urlLogo: 'https://midia.fake/logo/$nomeArquivo',
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
