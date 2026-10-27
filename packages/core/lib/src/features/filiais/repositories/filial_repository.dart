import 'dart:typed_data';

import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/nada.dart';
import 'package:tabloide_core/src/requests/filial_request.dart';
import 'package:tabloide_core/src/responses/filial_response.dart';

abstract interface class FilialRepository {
  Future<Either<Falha, List<FilialResponse>>> listar();

  Future<Either<Falha, FilialResponse>> obter(String id);

  Future<Either<Falha, FilialResponse>> criar(FilialRequest request);

  Future<Either<Falha, FilialResponse>> editar(
    String id,
    FilialRequest request,
  );

  Future<Either<Falha, Nada>> excluir(String id);

  /// PNG do QR Code da página pública da filial (512 px).
  Future<Either<Falha, Uint8List>> qrCode(String id);
}
