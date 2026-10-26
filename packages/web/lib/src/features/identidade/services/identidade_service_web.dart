import 'package:tabloide_core/tabloide_core.dart';

final class IdentidadeServiceWeb {
  const IdentidadeServiceWeb(this._repository);

  final IdentidadeRepository _repository;

  Future<Either<Falha, IdentidadeResponse>> obter() => _repository.obter();

  Future<Either<Falha, IdentidadeResponse>> editar(IdentidadeRequest request) =>
      _repository.editar(request);

  Future<Either<Falha, IdentidadeResponse>> enviarLogo({
    required List<int> bytes,
    required String nomeArquivo,
  }) => _repository.enviarLogo(bytes: bytes, nomeArquivo: nomeArquivo);
}
