import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/requests/configuracao_pagina_request.dart';
import 'package:tabloide_core/src/responses/configuracao_pagina_response.dart';

/// Aparência da página pública do lojista (plano.md §4.2 e §4.3). Toda rota
/// devolve a configuração inteira.
abstract interface class ConfiguracaoPaginaRepository {
  Future<Either<Falha, ConfiguracaoPaginaResponse>> obter();

  Future<Either<Falha, ConfiguracaoPaginaResponse>> editar(
    ConfiguracaoPaginaRequest request,
  );

  Future<Either<Falha, ConfiguracaoPaginaResponse>> enviarLogoBanner({
    required List<int> bytes,
    required String nomeArquivo,
  });

  Future<Either<Falha, ConfiguracaoPaginaResponse>> removerLogoBanner();

  Future<Either<Falha, ConfiguracaoPaginaResponse>> enviarFotoBanner({
    required List<int> bytes,
    required String nomeArquivo,
  });

  Future<Either<Falha, ConfiguracaoPaginaResponse>> removerFotoBanner();
}
