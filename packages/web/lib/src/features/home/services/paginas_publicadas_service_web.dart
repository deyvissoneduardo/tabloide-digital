import 'dart:typed_data';

import 'package:tabloide_web/src/features/home/contexto_paginas.dart';
import 'package:tabloide_core/tabloide_core.dart';

final class PaginasPublicadasServiceWeb {
  const PaginasPublicadasServiceWeb(
    this._identidade,
    this._lojista,
    this._filiais,
  );

  final IdentidadeRepository _identidade;

  final LojistaRepository _lojista;

  final FilialRepository _filiais;

  /// Identidade e lojista em paralelo; a primeira falha vence.
  Future<Either<Falha, ContextoPaginas>> carregar() async {
    final (identidade, lojista) = await (
      _identidade.obter(),
      _lojista.obter(),
    ).wait;
    return switch ((identidade, lojista)) {
      (Failure(:final falha), _) ||
      (_, Failure(:final falha)) => Failure(falha),
      (Success(valor: final identidade), Success(valor: final lojista)) =>
        Success(
          ContextoPaginas(
            sePanfleto: identidade.sePanfleto,
            contaAtiva: lojista.status == 'ATIVO',
            nomeFantasia: identidade.nomeFantasia,
          ),
        ),
    };
  }

  Future<Either<Falha, Uint8List>> qrCode(String filialId) =>
      _filiais.qrCode(filialId);
}
